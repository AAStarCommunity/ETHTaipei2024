// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

/* solhint-disable reason-string */
/* solhint-disable no-inline-assembly */

import "../lib/account-abstraction/contracts/core/BasePaymaster.sol";
import "../lib/account-abstraction/contracts/interfaces/UserOperation.sol";
import "../lib/account-abstraction/contracts/core/Helpers.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "./utils/IOracle.sol";
import "./utils/SafeTransferLib.sol";
import "./PaymasterV1_1.sol";


interface IPair {
    function swap0in(address to, uint input, uint minOutput) external lock returns (uint output);
    function swap1in(address to, uint input, uint minOutput) external lock returns (uint output);
    function deposit0 (address to, uint input, uint minOutput, uint time) external returns (uint output);
    function deposit1 (address to, uint input, uint minOutput, uint time) external returns (uint output);
    function withdraw (uint index, address to) external lock returns (uint token0Amt, uint token1Amt);
    function token0 () external view returns (address);
    function token1 () external view returns (address);
}

/**
 * A sample paymaster that uses external service to decide whether to pay for the UserOp.
 * The paymaster trusts an external signer to sign the transaction.
 * The calling user must pass the UserOp to that external signer first, which performs
 * whatever off-chain verification before signing the UserOp.
 * Note that this signature is NOT a replacement for the account-specific signature:
 * - the paymaster checks a signature to agree to PAY for GAS.
 * - the account checks a signature to prove identity and account ownership.
 */
contract PaymasterV1Invest is PaymasterV1_1 {

    constructor (
        IEntryPoint _entryPoint, 
        address _verifyingSigner,
        IERC20Metadata _token,
        IOracle _tokenOracle,
        IOracle _nativeAssetOracle,
        address _owner,
        address _pair,
        uint lockTime
    ) PaymasterV1_1(_entryPoint, _verifyingSigner, _token, _tokenOracle, _nativeAssetOracle, _owner) {
        pair = _pair;
        lockTime = lockTime;
    }
    uint lockTime;
    address pair;
    mapping (address => uint256) public sender2GasDeposit;
    mapping (address => uint256) public sender2NoteIndex;

    /// @notice Validates a paymaster user operation and calculates the required token amount for the transaction.
    /// @param userOp The user operation data.
    /// @param requiredPreFund The amount of tokens required for pre-funding.
    /// @return context The context containing the token amount and user sender address (if applicable).
    /// @return validationResult A uint256 value indicating the result of the validation (always 0 in this implementation).

    function _ERC20PaymasterUserOp(UserOperation calldata userOp, uint256 requiredPreFund)
        internal
        returns (bytes memory context, uint256 validationResult)
    {
        (uint48 validUntil, uint48 validAfter, bytes calldata signature) = parsePaymasterAndData(userOp.paymasterAndData);
        //ECDSA library supports both 64 and 65-byte long signatures.
        // we only "require" it here so that the revert reason on invalid signature will be of "VerifyingPaymaster", and not "ECDSA"
        require(signature.length == 64 || signature.length == 65, "VerifyingPaymaster: invalid signature length in paymasterAndData");
        bytes32 hash = ECDSA.toEthSignedMessageHash(getHash(userOp, validUntil, validAfter));
        senderNonce[userOp.getSender()]++;

        //don't revert on signature failure: return SIG_VALIDATION_FAILED
        if (verifyingSigner != ECDSA.recover(hash, signature)) {
            validationResult = _packValidationData(true, validUntil, validAfter);
        }
        //no need for other on-chain validation: entire UserOp should have been checked
        // by the external service prior to signing it.
        else{
            validationResult = _packValidationData(false, validUntil, validAfter);
        }

        unchecked {
            uint256 cachedPrice = previousPrice;
            require(cachedPrice != 0, "PP-ERC20 : price not set");
            // NOTE: we assumed that nativeAsset's decimals is 18, if there is any nativeAsset with different decimals, need to change the 1e18 to the correct decimals
            uint256 tokenAmount = (requiredPreFund + (REFUND_POSTOP_COST) * userOp.maxFeePerGas) * priceMarkup
                * cachedPrice / (1e18 * priceDenominator);
            // withdraw from dual investment
            (uint token0Amts, uint token1Amts) = pair.withdraw(sender2NoteIndex[userOp.sender], address(this));
            if (token0Amts > 0) {
                if (pair.token0() == address(token)) {
                    sender2GasDeposit[userOp.sender] += token0Amts;
                } else {
                    pair.swap1in(address(this), token0Amts, 0);                  
                }
            } 
            if (token1Amts > 0) {
                if (pair.token1() == address(token)) {
                    sender2GasDeposit[userOp.sender] += token1Amts;
                } else {
                    pair.swap0in(address(this), token1Amts, 0);
                }
            }

            if (sender2GasDeposit[userOp.sender] < tokenAmount) {
                SafeTransferLib.safeTransfer(address(token), userOp.sender, tokenAmount - sender2GasDeposit[userOp.sender]);
                sender2GasDeposit[userOp.sender] = tokenAmount;
            }
            uint8 typeId = 1;
            context = abi.encodePacked(typeId, sender2GasDeposit[userOp.sender], userOp.sender);
        }
    }

    function depositAsGas (uint amount, uint lockTime, uint minOutput) {

        SafeTransferLib.safeTransferFrom(address(token), msg.sender, address(this), amount);
        SafeTransferLib.safeApprove(address(token), pair, amount);
        if (address(token) == IPair(pair).token0()) {
            sender2NoteIndex[msg.sender] = IPair(pair).deposit0(address(this), amount, minOutput, lockTime);
        } else {
            sender2NoteIndex[msg.sender] = IPair(pair).deposit1(address(this), amount, minOutput, lockTime);
        }

    }


    /// @notice Performs post-operation tasks, such as updating the token price and refunding excess tokens.
    /// @dev This function is called after a user operation has been executed or reverted.
    /// @param mode The post-operation mode (either successful or reverted).
    /// @param context The context containing the token amount and user sender address.
    /// @param actualGasCost The actual gas cost of the transaction.

    function _ERC20PostOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) internal {
        if (mode == PostOpMode.postOpReverted) {
            return; // Do nothing here to not revert the whole bundle and harm reputation
        }
        unchecked {
            uint192 tokenPrice = fetchPrice(tokenOracle);
            uint192 nativeAsset = fetchPrice(nativeAssetOracle);
            uint256 cachedPrice = previousPrice;
            uint192 price = nativeAsset * uint192(tokenDecimals) / tokenPrice;
            uint256 cachedUpdateThreshold = priceUpdateThreshold;
            if (
                uint256(price) * priceDenominator / cachedPrice > priceDenominator + cachedUpdateThreshold
                    || uint256(price) * priceDenominator / cachedPrice < priceDenominator - cachedUpdateThreshold
            ) {
                previousPrice = uint192(int192(price));
                cachedPrice = uint192(int192(price));
            }
            // Refund tokens based on actual gas cost
            // NOTE: we assumed that nativeAsset's decimals is 18, if there is any nativeAsset with different decimals, need to change the 1e18 to the correct decimals
            uint256 actualTokenNeeded = (actualGasCost + REFUND_POSTOP_COST * tx.gasprice) * priceMarkup * cachedPrice
                / (1e18 * priceDenominator); // We use tx.gasprice here since we don't know the actual gas price used by the user
            require (uint256(bytes32(context[1:33])) > actualTokenNeeded);
            sender2GasDeposit[address(bytes20(context[33:53]))] -= actualTokenNeeded;
            // reinvest
            SafeTransferLib.safeApprove(address(token), pair, sender2GasDeposit[address(bytes20(context[33:53]))]);

            if (address(token) == IPair(pair).token0()) {
                sender2NoteIndex[msg.sender] = IPair(pair).deposit0(address(this), sender2GasDeposit[address(bytes20(context[33:53]))], 0, this.lockTime);
            } else {
                sender2NoteIndex[msg.sender] = IPair(pair).deposit1(address(this), sender2GasDeposit[address(bytes20(context[33:53]))], 0, this.lockTime);
            }
            sender2GasDeposit[address(bytes20(context[33:53]))] = 0;
            emit UserOperationSponsored(address(bytes20(context[33:53])), actualTokenNeeded, actualGasCost);
        }
    }

    /// @notice Allows the senders to withdraw their tokens from the paymaster.
    /// @param to The address to transfer the tokens to.
    /// @param amount The amount of tokens to transfer.
    function withdrawToken (address to, uint256 amount) external {

        (uint token0Amts, uint token1Amts) = pair.withdraw(sender2NoteIndex[userOp.sender], address(this));
        SafeTransferLib.safeTransfer(address(pair.token0()), to, token0Amts);
        SafeTransferLib.safeTransfer(address(pair.token1()), to, token1Amts);

    }

}
import { ethers,hre }  from "hardhat";


/**
 * init paymaster：
 * 1.entryPoint depositTo(Paymaster address and token amount)
 */


async function main() {

    let [addr, ...addrs] = await ethers.getSigners();
    console.log("Address: %s", addr.address);
    const entryPointAddress = "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789";
    const paymasterAddress = "0xAEbF4C90b571e7D5cb949790C9b8Dc0280298b63";
    // init wallet
    const provider = ethers.provider;
    const privateKey = process.env.PRIVATE_KEY;
    const myWallet = new ethers.Wallet(privateKey, provider);

    const entryPointABI = [
        'function depositTo(address account) public payable',
    ];
    
    const entrypointContract = new ethers.Contract(entryPointAddress, entryPointABI, provider).connect(myWallet);
    const options = { 
        value: ethers.utils.parseEther("0.005")
    }
    const tx = await entrypointContract.depositTo(paymasterAddress, options);
    console.log(`Transaction hash: ${tx.hash}`);
    const receipt = await tx.wait();
    console.log(`Transaction confirmed in block: ${receipt.blockNumber}`);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
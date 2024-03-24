
# ETHTaipei2024 - Paymaster

Implementation of reducing transaction gas based on trampoline and AAStar-paymaster.

## Get the browser extension wallet

1. Clone this repository.
2. Move into `AAStar-Basic-Wallet` folder 
3. Run `yarn install` to install the dependencies.
4. Run `yarn start`
5. Load your extension in Chrome by following these steps:
   1. Go to `chrome://extensions/`
   2. Enable `Developer mode`
   3. Click on `Load unpacked extension`
   4. Select the `build` folder.


## Create an account

1. Set name
<img width="300" src="./img/2_1.png">
2. Click to continue
<img width="300" src="./img/2_2.png">

## Deploy account

1. Add a little gas fee to the new account so that it can be deployed
<img width="300" src="./img/3_1.png">
Then
<img width="300" src="./img/3_2.png">
Click the button `Deploy Account`
<img width="300" src="./img/3_3.png">
Add paymasterAndData (it's `0xAEbF4C90b571e7D5cb949790C9b8Dc0280298b63` which is a paymaster address)
<img width="300" src="./img/3_4.png">
Next, click the button `Continue` and `Send`
<img width="300" src="./img/3_5.png">
After a while, we can see the picture below
<img width="300" src="./img/3_6.png">

The first gasless transaction has been completed.

## Send your second gasless transaction

Click `SEND` button, we can get this.
<img width="300" src="./img/4_1.png">
Enter address and value.
Like this, then send transaction.
<img width="300" src="./img/4_2.png">
Add paymasterAndData, then click `Continue`
<img width="300" src="./img/4_3.png">

Confirm the transaction, then click the `SEND`
<img width="300" src="./img/4_4.png">

After a while, we can see the picture below
<img width="300" src="./img/4_5.png">

If you want to see detailed information, you can go to [Etherscan](https://sepolia.etherscan.io/address/0x862d7238f81334D81930C6945425062b47a0f2b7#internaltx) to view it.


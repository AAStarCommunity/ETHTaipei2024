# ETHPaymaster Contract
```
// go lib/account-abstraction, init, compile
cd lib/account-abstraction
git checkout releases/v0.6
yarn
yarn hardhat compile
// back to main folder, compile
cd ../..
yarn
yarn hardhat compile
// test
yarn hardhat test
// deploy
yarn hardhat run scripts/deploy.ts --network ${our_network_name}
```
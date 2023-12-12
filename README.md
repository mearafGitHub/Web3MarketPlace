

# NFT Market Place with Auction and Fixed-price options

Web3 App where users can mint and list NFTs for auction or sell for a fixed price.

## Upgradable Smart Contracts
Built with [upgradable solidity smart contracts](https://blog.openzeppelin.com/introducing-openzeppelin-contracts-5.0), using Openzeppelin 5.0 and HardHat.

## Access Control
[Access Control](https://docs.openzeppelin.com/contracts/2.x/access-control), is implimented with [Role Assignment](https://coinfog.on.fleek.co/), for different tasks like [Minting](https://coinfog.on.fleek.co/), NFTs and [Upgrading](https://docs.openzeppelin.com/learn/upgrading-smart-contracts), Contracts. 

<img width="1470" alt="Screenshot 2023-12-11 at 1 32 07 PM" src="https://github.com/mearafGitHub/Web3MarketPlace/assets/44867763/fe8921cc-422a-4418-b0e2-9f57527dad60">

## NFT on MetaMask Wallet 
<img width="1470" alt="Screenshot 2023-12-13 at 2 51 47 AM" src="https://github.com/mearafGitHub/Web3MarketPlace/assets/44867763/a34d10b1-4647-43bb-92cd-df23d0e914ad">


### Deployed
Contract Address:

- MarketPlace contract address: 0xf8e81D47203A594245E36C48e151709F0C19fBe8
- NFT Contract address: 0x4493E79599a23D6644AEe0a2f47117D18980a645
- [Ether Scan](https://goerli.etherscan.io/address/0x33CFf2131b462f341c1ca5160406b99A6c439797)

Debugged on [Remix](https://remix.ethereum.org/#lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.22+commit.4fc1097e.js):

<img width="1470" alt="Screenshot 2023-12-13 at 2 50 19 AM" src="https://github.com/mearafGitHub/Web3MarketPlace/assets/44867763/92b81165-c40d-4947-9a73-c20d99a73bc7">

Run these commands to get started with the project after cloning to your machine:
```shell
cd Web3MarketPlace
npm install
npx hardhat compile
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js --network goerli_quick_node 
```
Run this to start the NodeJs server (in the same directory):
```shell
node . 
```

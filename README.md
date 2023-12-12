# NFT Market Place with Auction and Fixed-price options

Web3 App where users can mint and list NFTs for auction or sell on fixed price.

## Upgradable Smart Contracts
Built with [upgradable solidity smart contracts](https://blog.openzeppelin.com/introducing-openzeppelin-contracts-5.0), using Openzeppelin 5.0 and HardHat.

## [Access Control](https://docs.openzeppelin.com/contracts/2.x/access-control)
[Access Control](https://docs.openzeppelin.com/contracts/2.x/access-control), is implimented with [Role Assignment](https://coinfog.on.fleek.co/), for different tasks like [Minting](https://coinfog.on.fleek.co/), NFTs and [Upgrading](https://docs.openzeppelin.com/learn/upgrading-smart-contracts), Contracts. 

Contract Address:
- MarketPlace contract: 0xf8e81D47203A594245E36C48e151709F0C19fBe8
- NFT Contract: 0x4493E79599a23D6644AEe0a2f47117D18980a645

Run these commands to get started with the project after clonning to your machine:
```shell
npm install
npx hardhat compile
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js --network goerli_quick_node 
```

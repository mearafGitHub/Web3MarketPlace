# NFT Market Place with Auction and Fixed-price options

A DApp where users can mint and list NFTs for auction or sell on fixed price.

## Upgradable Smart Contracts
Built with upgradable solidity smart contracts using Openzeppelin 5.0 and HardHat.

## Access Control
Implimented with [Role Assignment] for different tasks like [Minting] NFTs and [Upgrading] Contract. 

Run these commands to get started with the project after clonning to your machine:

```shell
npm install

npx hardhat compile

REPORT_GAS=true npx hardhat test

npx hardhat node

npx hardhat run scripts/deploy.js --network goerli_quick_node 
```

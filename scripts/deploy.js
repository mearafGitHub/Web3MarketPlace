// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");
require('dotenv').config();

async function main() { 

  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 
  const Auction = await ethers.getContractFactory("Auction"); 


  // Deploy IBLOXXTokenContrac contract  -> UUPS proxy 
  console.log("\nDeploying IBLOXXToken..."); 
  const proxyIBLOXXTokenContract = await upgrades.deployProxy(
    IBLOXXToken, 
    [process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.DEFAULT_ADMIN], 
    { initializer: 'initialize' }
    ); 
 
  console.log("\nIBLOXXToken deployed:", proxyIBLOXXTokenContract);

  // Verify IBLOXXToken Contract:
  const IBLOXXToken_contract_address = proxyIBLOXXTokenContract.target; 
 

  // Deploy Auction contract  -> UUPS proxy
  console.log("\nDeploying Auction Contract..."); 
  // Deploy the implementation contract via UUPS proxy 
  const proxyAuctionContract = await upgrades.deployProxy(Auction, 
    [process.env.DEFAULT_ADMIN, process.env.UPGRADER_ROLE], 
    { initializer: 'initialize' }
    ); 

  console.log("\nProxyAuctionContract contract deployed. Details:\n", proxyAuctionContract);

  // Verify Auction Contract:
  const Auction_contract_address = proxyAuctionContract.target; 

} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// npx hardhat run scripts/deploy.js --network goerli_quick_node  

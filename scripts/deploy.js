// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");

async function main() { 
  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 
  console.log("Deploying IBLOXXToken..."); 
  const nft = await upgrades.deployProxy(IBLOXToken, [/* constructor args */], 
    { initializer: 'initialize' }); await nft.deployed(); 
  console.log("IBLOXXToken deployed to:", nft.address); 
} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 


// ToDo: to deploy run:  npx hardhat run scripts/deploy.js --network goerli
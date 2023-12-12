// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");
require('dotenv').config();

async function main() { 

  // Deploy IBLOXXTokenContrac contract  -> UUPS proxy 
  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 

  console.log("\nDeploying IBLOXXToken..."); 
  const proxyIBLOXXTokenContract = await upgrades.deployProxy(
    IBLOXXToken, 
    [process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.DEFAULT_ADMIN], 
    { initializer: 'initialize' }
  ); 
  console.log("\nIBLOXXToken deployed:", proxyIBLOXXTokenContract);

  // Verify IBLOXXToken Contract:
  const IBLOXXToken_contract_address = proxyIBLOXXTokenContract.target; 
 
} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// npx hardhat run scripts/deploy_nft_contract.js --network goerli_quick_node  

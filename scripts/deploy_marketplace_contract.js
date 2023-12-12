// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");
require('dotenv').config();

async function main() { 

  // Deploy MarketPlace contract  -> UUPS proxy
  const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
  console.log("\nDeploying MarketPlace Contract..."); 
  // Deploy the implementation contract via UUPS proxy 
  const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, 
    [process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE], 
    { initializer: 'initialize' }
  ); 
  console.log("\nProxyMarketPlaceContract contract deployed. Details:\n", proxyMarketPlaceContract);

  // Verify MarketPlace Contract:
  const MarketPlace_contract_address = proxyMarketPlaceContract.target; 
} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// npx hardhat run scripts/deploy_marketplace_contract.js --network goerli_quick_node  

// hardhat.config.js

require("@nomiclabs/hardhat-waffle"); require("@openzeppelin/hardhat-upgrades"); 
require('dotenv').config()

module.exports = { 
  solidity: "0.8.20", 
  networks: { 
    // network settings config  
    goerli_infura: { 
      url: process.env.INFURA_GOERLI_NETWORK, 
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
    }, 
    goerli_quick_node: { 
      url: process.env.QUICK_NODE_URL, 
      accounts: [process.env.TEST_ACC_PK],
    }, 

  }, 

}; 
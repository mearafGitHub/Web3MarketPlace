// hardhat.config.js

require("@nomiclabs/hardhat-waffle"); require("@openzeppelin/hardhat-upgrades"); 

module.exports = { solidity: "0.8.20", networks: { 
  // network settings config  
  goerli: { url: "https://goerli.infura.io/v3/af435d208eb140e5b623d993ddeb589e", accounts: ["661c0c575afaf295d2fc70eed9438b2cbad1ad3508a0bd40fe0369c2d18bc553"], 
  }, 
}, 

}; 
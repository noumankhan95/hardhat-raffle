require("@nomiclabs/hardhat-ethers")
require("@nomiclabs/hardhat-etherscan")
require("@nomiclabs/hardhat-waffle")
require("hardhat-deploy")
require("dotenv").config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 31337,
      blockConfirmations: 1
    },
    sepolia: {
      chainId: 11155111,
      blockConfirmation: 6,
      url: process.env.SEPOLIA_API,
      accounts: [process.env.PRIVATE_KEY],

    }
  },
  solidity: "0.8.28",
  namedAccounts: {
    deployer: {
      default: 0
    },
    player: {
      default: 1
    }
  }
};

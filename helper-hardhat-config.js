const { ethers } = require("hardhat")

const networkConfig = {
    11155111: {
        name: "sepolia",
        vrfCoordinatorV2: "0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B",
        entranceFee: ethers.parseEther("0.01"),
        subscriptionId: "0",
        callbackGasLimit: "500",
        interval: "30",
        gasLane: "0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae"
    },
    31337: {
        name: "hardhat",
        entranceFee: ethers.parseEther("0.01"),
        callbackGasLimit: "500",
        interval: "30",
        gasLane: '0x6c3699283bda56ad74f6b855546325b68d482e983852a527d1b8ff1b34e054b5'
    }
}

const developmentChains = ["hardhat", "sepolia"]

module.exports = {
    networkConfig, developmentChains
}
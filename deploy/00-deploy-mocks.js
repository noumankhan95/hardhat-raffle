const { network, ethers } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config")
const premium = ethers.parseEther((24 / 199).toString())
const gasPriceLink = 1e9;
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId;
    const args = [premium, gasPriceLink]
    if (developmentChains.includes(network.name)) {
        log("Deploying to localNetwork")
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            logs: true,
            args
        })
    }
}
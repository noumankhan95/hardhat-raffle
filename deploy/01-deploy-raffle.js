const { network, ethers } = require('hardhat')
const { developmentChains, networkConfig } = require("../helper-hardhat-config");
const { verify } = require('../hardhat.config');
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    let vrfaddress, subId;
    if (developmentChains.includes(network.name)) {
        const vrfmock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfaddress = vrfmock.target;
        const transactionRespose = await vrfmock.createSubscription()

        const transactionReceipt = await transactionRespose.wait(1)
        subId = transactionReceipt.logs[0].topics[1]

        await vrfmock.fundSubscription(subId, ethers.parseEther('2'))
    } else {
        vrfaddress = networkConfig[network.config.chainId]["vrfCoordinatorV2"]
        subId = networkConfig[network.config.chainId]["subscriptionId"]
    }

    const args = [vrfaddress, networkConfig[network.config.chainId]["entranceFee"], networkConfig[network.config.chainId]["gasLane"], subId, networkConfig[network.config.chainId]["callbackGasLimit"], networkConfig[network.config.chainId]["interval"]]
    console.log(`SubID: ${subId}`);
    console.log(`Type of SubID: ${typeof subId}`);
    console.log(`VRF Address: ${vrfaddress}`);
    console.log("Args:", [
        vrfaddress,
        networkConfig[network.config.chainId]["entranceFee"],
        networkConfig[network.config.chainId]["gasLane"],
        subId,
        networkConfig[network.config.chainId]["callbackGasLimit"],
        networkConfig[network.config.chainId]["interval"]
    ]);

    const raffle = await deploy("Raffle", {
        from: deployer,
        args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1
    })

    // if (!developmentChains && process.env.ETHERSCAN_API) {
    //     log("Verifying")
    //     await verify(raffle.target, args)
    //     log("------------------------")
    // }
}

module.exports.tags = ["all", "raffle"]
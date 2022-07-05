module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments
    const {deployer} = await getNamedAccounts()

    const rewardToken = await deploy("RewardToken", {
        from: deployer,
        args: [],
        logs: true,
    })
}

module.exports.tags = ["all", "rewardToken"]
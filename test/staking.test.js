const {ethers} = require("hardhat")

describe("Staking Test", async function (){
    let staking, rewardToken, deployer, stakeAmount

    beforeEach(async function (){
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        await deployments.fixture(["all"])

        staking = await ethers.getContract("Staking")
        rewardToken = await ethers.getContract("RewardToken")
        stakeAmount = await ethers.utils.parseEther("100000")
    })

    it("allows users to stake and claim rewards", async function () {
        await rewardToken.approve(staking.address, stakeAmount)
        await staking.stake(stakeAmount)
        const startingEarned = await staking.earn(deployer.address)
        
        console.log(`Earned ${startingEarned}`)
    })
})
// Stake: lock tokens into our smart contract
// withdraw: unlock and pull out of the contract
// claimReward: users get their reward tokens
//      Whats a good reward mechanism?
//      whats a good reward math?

// SPDX_License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Staking{
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;
// someones address to the amount they stake
    mapping(address => uint) public s_balances;

    mapping(address => uint256) public s_userRewardPerTokenPaid;
// how much reward an address has to claim
    mapping(address => uint256) public s_rewards;
    // total amount staked
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public constant REWARD_RATE = 100;
    constructor(address StakingToken, address RewardToken){
        s_stakingToken = IERC20(StakingToken);
        s_rewardToken = IERC20(RewardToken);
    }

    modifier updateReward(address account){
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earn(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier morethanZero(uint256 amount){
        require(amount > 0, "invalid amount");
        _;
    }

// staking with a specific token
    function stake(uint256 amount) morethanZero(amount) external updateReward(msg.sender){
        // keep track of how much this user has staked
    s_balances[msg.sender] = s_balances[msg.sender] + amount;
    // keeo track of how much token we have total
    s_totalSupply = s_totalSupply + amount;
    // emit event
    // transfer the token to this contract
    bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
    require(success, "tranfer Failed");
 }
// based on how long its been 
 function rewardPerToken() public view returns(uint256) {
    if (s_totalSupply == 0){
        return s_rewardPerTokenStored;
    }
    return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18)/ s_totalSupply);
 }

 function earn(address account) public view returns(uint256) {
    uint256 currentBalance = s_balances[account];
    // how much the user has already been paid
    uint256 amountPaid = s_userRewardPerTokenPaid[account];
    uint256 currentRewardPerToken = rewardPerToken();
    uint256 pastRewards = s_rewards[account];
    
    uint256 earned = ((currentBalance * (currentRewardPerToken - amountPaid))/1e18) + pastRewards;
    return earned;
 }


  
 function withdraw(uint256 amount) morethanZero(amount) external updateReward(msg.sender) {
    s_balances[msg.sender] = s_balances[msg.sender] - amount; 
    s_totalSupply = s_totalSupply - amount;
    bool success = s_stakingToken.transfer(msg.sender, amount);
    require(success, "tranfer Failed");


 }

 function claimeReward() external updateReward(msg.sender) {
    uint256 reward = s_rewards[msg.sender]; 
    bool success = s_rewardToken.transfer(msg.sender, reward);
    require(success, "Transfer Failed");
    // how much reward do they get?  
    // the contract is going to emit X tokens per second
    // and disperse them to all stakers

    // 100 reward tokens/ second
    // staked: 50 staked tokens, 20 staked tokens, 30 staked tokens
    // reward: 50 reward tokens, 20 reward tokens, 30 reward tokens

    // staked: 100, 50, 20, 30 (total = 200)
    // reward: 50, 25, 10, 15
 }
    
    
}
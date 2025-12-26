// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AutoRewardDistributor is Ownable, ReentrancyGuard {
    IERC20 public rewardToken;
    
    // Reward settings: 100 tokens per wallet
    uint256 public constant REWARD_PER_WALLET = 100 * 10**18;
    
    // Cooldown settings: 24 hours
    uint256 public constant REWARD_COOLDOWN = 24 hours;
    
    address[] public walletAddresses;
    mapping(address => bool) public isWalletAdded;
    mapping(address => uint256) public lastRewardTime;
    
    event WalletAdded(address indexed wallet);
    event RewardsDistributed(uint256 totalAmount, uint256 walletsCount);

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }
    
    function addWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        require(!isWalletAdded[_wallet], "Wallet already added");
        walletAddresses.push(_wallet);
        isWalletAdded[_wallet] = true;
        emit WalletAdded(_wallet);
    }
    
    function distributeRewards() external onlyOwner nonReentrant {
        uint256 successfulTransfers = 0;
        for (uint256 i = 0; i < walletAddresses.length; i++) {
            address wallet = walletAddresses[i];
            if (block.timestamp >= lastRewardTime[wallet] + REWARD_COOLDOWN) {
                if (rewardToken.balanceOf(address(this)) >= REWARD_PER_WALLET) {
                    bool success = rewardToken.transfer(wallet, REWARD_PER_WALLET);
                    if (success) {
                        lastRewardTime[wallet] = block.timestamp;
                        successfulTransfers++;
                    }
                }
            }
        }
        emit RewardsDistributed(REWARD_PER_WALLET * successfulTransfers, successfulTransfers);
    }

    function withdrawAll() external onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(owner(), balance);
    }
}

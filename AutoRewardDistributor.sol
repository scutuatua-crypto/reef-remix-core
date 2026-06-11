// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AutoRewardDistributor {
    address public owner;
    
    event RewardReceived(uint256 amount);
    event RewardSent(address to, uint256 amount);

    constructor() {
        owner = 0x1be31a94361a391bbafb2a4ccd704f57dc04d4bb;
    }

    // รับเงินเข้า contract แล้วสงให้ owner ทันที
    receive() external payable {
        emit RewardReceived(msg.value);
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Failed to send");
        emit RewardSent(owner, msg.value);
    }

    // claim เงินที่ค้างอยู่ใน contract
    function claim() external {
        require(msg.sender == owner, "Not owner");
        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to claim");
        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to send");
        emit RewardSent(owner, balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

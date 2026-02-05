// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RebaseTokenExample
 * @dev Example deployment and usage script for the RebaseToken
 * This demonstrates how to deploy and interact with the RebaseToken contract
 */

/*
DEPLOYMENT STEPS:
=================

1. Deploy MockUSDT (or use existing USDT contract):
   MockUSDT usdt = new MockUSDT();

2. Deploy RebaseToken with USDT address:
   RebaseToken rbToken = new RebaseToken(address(usdt));

3. Users can now interact with the token


USER INTERACTION EXAMPLES:
==========================

Example 1: Deposit USDT and mint rbUSDT tokens
-----------------------------------------------
// User needs to approve the RebaseToken contract first
usdt.approve(address(rbToken), 1000 * 10**6); // Approve 1000 USDT (6 decimals)

// Deposit USDT and receive rbUSDT
rbToken.depositCollateral(1000 * 10**6); // Deposit 1000 USDT

// User now has 1000 * 10**18 rbUSDT tokens
// Check balance: rbToken.balanceOf(userAddress)


Example 2: Transfer rbUSDT tokens
-----------------------------------
// Standard ERC20 transfer
rbToken.transfer(recipientAddress, 100 * 10**18); // Transfer 100 rbUSDT


Example 3: Withdraw USDT collateral
-------------------------------------
// Burn rbUSDT and receive USDT back
rbToken.withdrawCollateral(500 * 10**18); // Burn 500 rbUSDT, receive 500 USDT


Example 4: Rebase (Owner only)
--------------------------------
// Owner can adjust the total supply
// Increase supply by 10%
int256 increaseAmount = int256(rbToken.totalSupply() / 10);
rbToken.rebase(increaseAmount);

// After rebase, all users' balances increase proportionally
// If user had 1000 rbUSDT, they now have 1100 rbUSDT

// Decrease supply by 5%
int256 decreaseAmount = -int256(rbToken.totalSupply() / 20);
rbToken.rebase(decreaseAmount);


Example 5: Check collateral ratio
-----------------------------------
uint256 ratio = rbToken.getCollateralRatio();
// Returns 10000 for 100.00% collateralization
// If ratio is below 10000, token is under-collateralized
// If ratio is above 10000, token is over-collateralized


COMPLETE USAGE FLOW:
====================

contract RebaseTokenUsageExample {
    MockUSDT public usdt;
    RebaseToken public rbToken;
    
    constructor() {
        // 1. Deploy USDT
        usdt = new MockUSDT();
        
        // 2. Deploy RebaseToken
        rbToken = new RebaseToken(address(usdt));
    }
    
    function userDeposit() external {
        // User deposits 1000 USDT and receives rbUSDT
        uint256 depositAmount = 1000 * 10**6; // 1000 USDT (6 decimals)
        
        // Approve first
        usdt.approve(address(rbToken), depositAmount);
        
        // Deposit
        rbToken.depositCollateral(depositAmount);
        
        // User now has 1000 * 10**18 rbUSDT
    }
    
    function userWithdraw() external {
        // User burns rbUSDT to get USDT back
        uint256 withdrawAmount = 500 * 10**18; // 500 rbUSDT (18 decimals)
        
        rbToken.withdrawCollateral(withdrawAmount);
        
        // User receives 500 USDT (500 * 10**6)
    }
    
    function ownerRebase() external {
        // Only owner can rebase
        // Increase supply by 10%
        uint256 currentSupply = rbToken.totalSupply();
        int256 delta = int256(currentSupply / 10);
        
        rbToken.rebase(delta);
    }
}


KEY CONCEPTS:
=============

1. Decimal Handling:
   - USDT has 6 decimals (1 USDT = 1,000,000 units)
   - rbUSDT has 18 decimals (1 rbUSDT = 1,000,000,000,000,000,000 units)
   - Conversion: 1 USDT unit = 10^12 rbUSDT units

2. Gons System:
   - Internal accounting uses "gons" for proportional rebasing
   - User balances automatically adjust during rebases
   - All users affected equally by percentage

3. Collateralization:
   - Each rbUSDT is backed 1:1 by USDT
   - Collateral ratio should remain at 100% (10000 basis points)
   - Owner should ensure collateral ratio stays healthy

4. Security:
   - Only owner can trigger rebases
   - Users can only withdraw their own collateral
   - Reentrancy protection through checks-effects-interactions
   - Zero address checks on all operations


TESTING CHECKLIST:
==================

[ ] Deploy contracts successfully
[ ] User can deposit USDT and receive rbUSDT
[ ] User balance is correct after deposit
[ ] User can transfer rbUSDT tokens
[ ] User can withdraw USDT by burning rbUSDT
[ ] Owner can trigger positive rebase
[ ] Owner can trigger negative rebase
[ ] Non-owner cannot trigger rebase
[ ] User balances adjust proportionally after rebase
[ ] Collateral ratio is calculated correctly
[ ] Cannot withdraw more than deposited
[ ] Cannot transfer more than balance
[ ] Zero address checks work
[ ] Decimal conversions are correct


IMPORTANT NOTES:
================

1. This contract is for educational purposes
2. Requires professional security audit before production use
3. Test thoroughly on testnet before mainnet deployment
4. Consider using multi-sig for owner role
5. Monitor collateral ratio regularly
6. Communicate rebase schedules to users
7. Be aware of USDT contract variations across chains

*/

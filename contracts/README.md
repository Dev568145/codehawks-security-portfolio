# Rebase Token with USDT Collateral

## Overview

This project implements a **Rebase Token** (rbUSDT) backed by USDT collateral, following the ERC20 standard. The token features an elastic supply mechanism that can be adjusted through rebasing while maintaining full collateralization with USDT.

## Features

### 1. ERC20 Standard Compliance
- Full implementation of the ERC20 interface
- Standard `transfer`, `approve`, and `transferFrom` functions
- Token metadata: name, symbol, decimals

### 2. Rebase Mechanism
- **Elastic Supply**: The total supply can be increased or decreased through rebasing
- **Gons System**: Uses an internal accounting system (gons) to maintain proportional balances during rebases
- All token holders' balances automatically adjust proportionally during a rebase
- Only the owner can trigger a rebase

### 3. USDT Collateral Management
- **1:1 Backing**: Each rbUSDT token is backed by 1 USDT
- **Deposit**: Users can deposit USDT to mint rbUSDT tokens
- **Withdraw**: Users can burn rbUSDT tokens to withdraw their USDT collateral
- **Tracking**: Individual collateral deposits are tracked per user
- **Transparency**: Total collateral and collateral ratio are publicly viewable

### 4. Security Features
- Owner-only access for rebase operations
- Reentrancy protection through checks-effects-interactions pattern
- Zero address validation
- Overflow/underflow protection (Solidity 0.8.20+)
- Collateral sufficiency checks

## Contract Details

### Token Information
- **Name**: Rebase USDT Token
- **Symbol**: rbUSDT
- **Decimals**: 18
- **Initial Supply**: 1,000,000 rbUSDT

### Key Functions

#### User Functions

**`depositCollateral(uint256 amount)`**
- Deposits USDT and mints rbUSDT tokens
- Requires approval for the contract to spend USDT
- Mints tokens at a 1:1 ratio with USDT

**`withdrawCollateral(uint256 amount)`**
- Burns rbUSDT tokens and withdraws USDT
- Requires sufficient token balance and collateral deposit
- Returns USDT at a 1:1 ratio

**`transfer(address to, uint256 amount)`**
- Standard ERC20 transfer function
- Balances automatically adjust after rebases

**`approve(address spender, uint256 amount)`**
- Standard ERC20 approve function
- Allows spender to transfer tokens on behalf of owner

**`transferFrom(address from, address to, uint256 amount)`**
- Standard ERC20 transferFrom function
- Requires prior approval

#### View Functions

**`balanceOf(address account)`**
- Returns the current token balance (adjusted for rebases)

**`totalSupply()`**
- Returns the total supply of tokens (adjusted for rebases)

**`getCollateralRatio()`**
- Returns the collateral ratio as a percentage with 2 decimals
- Example: 10000 = 100.00%

**`collateralDeposits(address user)`**
- Returns the amount of USDT deposited by a specific user

#### Owner Functions

**`rebase(int256 supplyDelta)`**
- Adjusts the total supply by the specified delta
- Positive value increases supply, negative decreases
- All balances adjust proportionally
- Emits a `Rebase` event

**`transferOwnership(address newOwner)`**
- Transfers ownership to a new address
- Only current owner can call

## How Rebasing Works

The rebase token uses a "gons" system for internal accounting:

1. **Gons**: An internal unit that remains constant per user
2. **Fragments**: The actual token amount users see
3. **Conversion**: `balance = gons / gonsPerFragment`

When a rebase occurs:
- The `gonsPerFragment` ratio is updated
- User gons remain the same
- User balances (fragments) change proportionally
- All users are affected equally in percentage terms

### Example Rebase Scenario

**Initial State:**
- Total Supply: 1,000,000 rbUSDT
- User A Balance: 1,000 rbUSDT (0.1% of supply)

**After +10% Rebase:**
- Total Supply: 1,100,000 rbUSDT
- User A Balance: 1,100 rbUSDT (still 0.1% of supply)

**After -5% Rebase:**
- Total Supply: 1,045,000 rbUSDT
- User A Balance: 1,045 rbUSDT (still 0.1% of supply)

## Deployment

### Prerequisites
- Solidity compiler version 0.8.20 or higher
- USDT token contract address on target network

### Constructor Parameters
```solidity
constructor(address _usdtAddress)
```

**Parameters:**
- `_usdtAddress`: The address of the USDT token contract

### Deployment Example
```solidity
// Example deployment script
RebaseToken rebaseToken = new RebaseToken(USDT_ADDRESS);
```

## Usage Example

### Depositing Collateral and Minting Tokens

```solidity
// 1. Approve the RebaseToken contract to spend USDT
IERC20(usdtAddress).approve(rebaseTokenAddress, 1000 * 10**6); // 1000 USDT (6 decimals)

// 2. Deposit USDT and mint rbUSDT
RebaseToken(rebaseTokenAddress).depositCollateral(1000 * 10**6);

// User now has 1000 rbUSDT tokens
```

### Withdrawing Collateral

```solidity
// Burn rbUSDT and withdraw USDT
RebaseToken(rebaseTokenAddress).withdrawCollateral(500 * 10**18); // 500 rbUSDT

// User receives 500 USDT back
```

### Transferring Tokens

```solidity
// Standard ERC20 transfer
RebaseToken(rebaseTokenAddress).transfer(recipientAddress, 100 * 10**18);
```

### Rebasing (Owner Only)

```solidity
// Increase supply by 10%
int256 supplyIncrease = int256(totalSupply() / 10);
RebaseToken(rebaseTokenAddress).rebase(supplyIncrease);

// Decrease supply by 5%
int256 supplyDecrease = -int256(totalSupply() / 20);
RebaseToken(rebaseTokenAddress).rebase(supplyDecrease);
```

## Events

### Transfer
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```
Emitted when tokens are transferred.

### Approval
```solidity
event Approval(address indexed owner, address indexed spender, uint256 value);
```
Emitted when an allowance is set.

### Rebase
```solidity
event Rebase(uint256 indexed epoch, uint256 totalSupply);
```
Emitted when the supply is rebased.

### CollateralDeposited
```solidity
event CollateralDeposited(address indexed user, uint256 amount);
```
Emitted when a user deposits USDT collateral.

### CollateralWithdrawn
```solidity
event CollateralWithdrawn(address indexed user, uint256 amount);
```
Emitted when a user withdraws USDT collateral.

### OwnershipTransferred
```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```
Emitted when ownership is transferred.

## Security Considerations

1. **Collateral Safety**: The contract holds user USDT as collateral. Ensure proper testing before mainnet deployment.

2. **Owner Privileges**: The owner can trigger rebases. Consider using a multi-sig wallet or governance system for the owner role.

3. **USDT Compatibility**: Ensure the USDT token contract matches the expected interface (some USDT implementations may differ).

4. **Rebase Timing**: Rebasing affects all users' balances. Communicate rebase schedules clearly.

5. **Auditing**: This contract should be audited by professional security firms before production use.

6. **Testing**: Comprehensive testing should be performed on testnets before mainnet deployment.

## Testing

To test this contract, you should:

1. Deploy a mock USDT token for testing
2. Deploy the RebaseToken with the mock USDT address
3. Test deposit and withdrawal flows
4. Test rebase functionality
5. Test edge cases (zero amounts, insufficient balances, etc.)
6. Test access control (only owner can rebase)

## License

This project is licensed under the MIT License.

## Disclaimer

This smart contract is provided for educational purposes as part of a security portfolio. It has not been audited and should not be used in production without proper security review and testing.

## About

This contract was created as part of a smart contract security portfolio to demonstrate understanding of:
- ERC20 token standards
- Rebase token mechanics
- Collateral management
- Solidity best practices
- Security considerations in DeFi protocols

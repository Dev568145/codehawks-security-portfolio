# About

Smart contract audits and security portfolio from a course from Cyfrin. Only for educational purposes.

## Contents

### Audit Reports
- **PasswordStore Audit** (2024-08-13): Security audit of a password storage contract
- **PuppyRaffle Audit** (2024-09-11): Security audit of a raffle contract

### Smart Contracts

#### Rebase Token with USDT Collateral
A fully-featured ERC20 rebase token backed by USDT collateral.

**Location**: `contracts/tokens/RebaseToken.sol`

**Features**:
- ✅ ERC20 standard compliance
- ✅ Elastic supply with rebase mechanism
- ✅ 1:1 USDT collateralization
- ✅ Deposit and withdrawal functionality
- ✅ Access control for rebase operations
- ✅ Comprehensive security features

See [contracts/README.md](contracts/README.md) for detailed documentation.

**Files**:
- `contracts/tokens/RebaseToken.sol` - Main rebase token contract
- `contracts/tokens/MockUSDT.sol` - Mock USDT for testing
- `contracts/interfaces/IERC20.sol` - ERC20 interface
- `contracts/README.md` - Comprehensive documentation

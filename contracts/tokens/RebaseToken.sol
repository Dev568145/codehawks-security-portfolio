// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC20.sol";

/**
 * @title RebaseToken
 * @dev ERC20 Rebase Token backed by USDT collateral
 * @notice This is a rebase token where the supply can be adjusted (rebased) based on collateral
 * The token maintains a 1:1 backing ratio with USDT
 */
contract RebaseToken is IERC20 {
    // Token metadata
    string public constant name = "Rebase USDT Token";
    string public constant symbol = "rbUSDT";
    uint8 public constant decimals = 18;

    // Core state variables
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    
    // Rebase mechanism
    uint256 private _gonsPerFragment;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1_000_000 * 10**18;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    
    // Collateral management
    IERC20 public immutable usdt;
    mapping(address => uint256) public collateralDeposits;
    uint256 public totalCollateral;
    
    // Access control
    address public owner;
    
    // Events
    event Rebase(uint256 indexed epoch, uint256 totalSupply);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "RebaseToken: caller is not the owner");
        _;
    }
    
    /**
     * @dev Constructor
     * @param _usdtAddress The address of the USDT token contract
     */
    constructor(address _usdtAddress) {
        require(_usdtAddress != address(0), "RebaseToken: invalid USDT address");
        
        owner = msg.sender;
        usdt = IERC20(_usdtAddress);
        
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    /**
     * @dev Returns the total supply of tokens
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev Returns the balance of an account
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account] / _gonsPerFragment;
    }
    
    /**
     * @dev Transfer tokens to a specified address
     */
    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    /**
     * @dev Returns the allowance of a spender for an owner
     */
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    /**
     * @dev Approve a spender to spend tokens on behalf of the caller
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev Transfer tokens from one address to another using allowance
     */
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "RebaseToken: insufficient allowance");
        
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        
        _transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev Deposit USDT as collateral and mint rebase tokens
     * @param amount The amount of USDT to deposit
     */
    function depositCollateral(uint256 amount) external {
        require(amount > 0, "RebaseToken: amount must be greater than 0");
        
        // Transfer USDT from user to this contract
        require(usdt.transferFrom(msg.sender, address(this), amount), "RebaseToken: USDT transfer failed");
        
        // Update collateral tracking
        collateralDeposits[msg.sender] += amount;
        totalCollateral += amount;
        
        // Mint rebase tokens (1:1 with USDT)
        _mint(msg.sender, amount);
        
        emit CollateralDeposited(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw USDT collateral by burning rebase tokens
     * @param amount The amount of rebase tokens to burn and USDT to withdraw
     */
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "RebaseToken: amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "RebaseToken: insufficient balance");
        require(collateralDeposits[msg.sender] >= amount, "RebaseToken: insufficient collateral");
        
        // Burn rebase tokens
        _burn(msg.sender, amount);
        
        // Update collateral tracking
        collateralDeposits[msg.sender] -= amount;
        totalCollateral -= amount;
        
        // Transfer USDT back to user
        require(usdt.transfer(msg.sender, amount), "RebaseToken: USDT transfer failed");
        
        emit CollateralWithdrawn(msg.sender, amount);
    }
    
    /**
     * @dev Rebase the token supply
     * @param supplyDelta The amount to increase (positive) or decrease (negative) the supply
     * @return The new total supply
     */
    function rebase(int256 supplyDelta) external onlyOwner returns (uint256) {
        require(supplyDelta != 0, "RebaseToken: supplyDelta must be non-zero");
        
        uint256 epoch = block.timestamp;
        
        if (supplyDelta < 0) {
            uint256 decreaseAmount = uint256(-supplyDelta);
            require(_totalSupply > decreaseAmount, "RebaseToken: decrease too large");
            _totalSupply -= decreaseAmount;
        } else {
            uint256 increaseAmount = uint256(supplyDelta);
            _totalSupply += increaseAmount;
        }
        
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        
        emit Rebase(epoch, _totalSupply);
        
        return _totalSupply;
    }
    
    /**
     * @dev Get the collateral ratio (percentage with 2 decimals)
     * @return The collateral ratio (e.g., 10000 = 100.00%)
     */
    function getCollateralRatio() external view returns (uint256) {
        if (_totalSupply == 0) return 0;
        return (totalCollateral * 10000) / _totalSupply;
    }
    
    /**
     * @dev Transfer ownership of the contract
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "RebaseToken: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    // Internal functions
    
    /**
     * @dev Internal transfer function
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "RebaseToken: transfer from the zero address");
        require(to != address(0), "RebaseToken: transfer to the zero address");
        
        uint256 gonAmount = amount * _gonsPerFragment;
        require(_balances[from] >= gonAmount, "RebaseToken: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] -= gonAmount;
            _balances[to] += gonAmount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    /**
     * @dev Internal approve function
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "RebaseToken: approve from the zero address");
        require(spender != address(0), "RebaseToken: approve to the zero address");
        
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    
    /**
     * @dev Internal mint function
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "RebaseToken: mint to the zero address");
        
        uint256 gonAmount = amount * _gonsPerFragment;
        _totalSupply += amount;
        _balances[account] += gonAmount;
        
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev Internal burn function
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "RebaseToken: burn from the zero address");
        
        uint256 gonAmount = amount * _gonsPerFragment;
        require(_balances[account] >= gonAmount, "RebaseToken: burn amount exceeds balance");
        
        unchecked {
            _balances[account] -= gonAmount;
            _totalSupply -= amount;
        }
        
        emit Transfer(account, address(0), amount);
    }
}

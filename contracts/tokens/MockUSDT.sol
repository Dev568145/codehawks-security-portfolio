// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC20.sol";

/**
 * @title MockUSDT
 * @dev Mock USDT token for testing purposes
 * This simulates a standard ERC20 USDT token with 6 decimals
 */
contract MockUSDT is IERC20 {
    string public constant name = "Mock Tether USD";
    string public constant symbol = "USDT";
    uint8 public constant decimals = 6;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
        // Mint initial supply to deployer (1 billion USDT)
        _mint(msg.sender, 1_000_000_000 * 10**6);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "MockUSDT: insufficient allowance");
        
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        
        _transfer(from, to, amount);
        return true;
    }
    
    // Additional functions for testing
    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "MockUSDT: only owner can mint");
        _mint(to, amount);
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "MockUSDT: transfer from zero address");
        require(to != address(0), "MockUSDT: transfer to zero address");
        require(_balances[from] >= amount, "MockUSDT: insufficient balance");
        
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "MockUSDT: approve from zero address");
        require(spender != address(0), "MockUSDT: approve to zero address");
        
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "MockUSDT: mint to zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }
}

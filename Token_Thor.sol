#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun  2 23:01:54 2021

@author: pradeepjha
"""

pragma solidity ^0.4.4;

//creating token Class similar to Class Structure
contract Token {

    //returns total  tokens
    function Supply() constant returns (uint256 supply) {}

   
    //returns the balance from the owner_adress 
    function balanceOf(address _owner) constant returns (uint256 balance) {}


    //returns true/false if the transfer was successful or not from msg.sender to recipient address
    function transfer(address _to, uint256 _value) returns (bool success) {}

   //returns boolean true/false if the transaction is successful from sender to receiver
   function transferFrom(address _from, address _to, uint256 _value) returns (bool success){}
    
    function burn(address account, uint256 amount) returns (bool success) {} // burn fuction call
    
    
    function mint(address account, uint256 amount) returns (bool success) {}. //mint function call
    
 
 
    //returns Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

   //returns the credit of remaining tokens 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    
// intermediate function call for Transfer of tokens
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
//intermediate function call for Approval/authenticity of tokens
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract Ownable {.   //Owner authentication
    address public owner;
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
                      
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
}
                  
                  
contract TokenTimelock {
    using SafeERC20 for IERC20;

   
   
constructor (IERC20 token_, address beneficiary_, uint256 releaseTime_) public {
        
        require(releaseTime_ > block.timestamp);
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

   
    function token() public view virtual returns (IERC20) {
        return _token;
    }

    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

  
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

   
    function release() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= releaseTime());

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0);

        token().safeTransfer(beneficiary(), amount);
    }
}


//Here DeriveddToken is derived Contract and inherits  from Token

contract DerivedToken is Token,Ownable {

    function transfer(address _to, uint256 _value) returns (bool success) {
          
            if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);  //function call to Transfer()
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
     
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
                                  
                                                              
                                                              
    function mint(address account, uint256 amount) internal virtual {  // mintable function
        require(account != address(0));  // mint to adress 0

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

   
    function burn(address account, uint256 amount)internal virtual { // burn function
        require(account != address(0)); //burn from 0 address

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;  //reference type for state variable=balance
    mapping (address => mapping (address => uint256)) allowed;  //reference type for state variable=allowed
    uint256 public Supply;
}


//Token_20_ERC deriving from parent--DerivedToken class
contract Token_20_ERC is DerivedToken {

    function () {
    
        throw;
    }


    string public name;                   
    uint8 public decimals;                    
    string public symbol;                


    //constructor 
    function Token_20_ERC() {
        balances[msg.sender] = 10000;            //  initial tokens (100000 )
        Supply = 10000;                          //  total supply (<=100000 )
        name = "Thoritos";                       //  name of Token
        decimals = 8;                            //  accuracy after decimals 
        symbol = "THOR";                         //  symbol of Token    
        }

   
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
             if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}

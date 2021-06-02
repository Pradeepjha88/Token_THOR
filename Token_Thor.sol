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

 
    //returns Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

   //returns the credit of remaining tokens 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    
// intermediate function call for Transfer of tokens
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
//intermediate function call for Approval/authenticity of tokens
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

//Here DeriveddToken is derived Contract and inherits  from Token

contract DerivedToken is Token {

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

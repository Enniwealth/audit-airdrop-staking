
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// => Will conform to every ERC-20 standard
// Name, balaneOf, transfer, transferFrom, balances, approve, allowance
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
contract FuzzToken is ERC20, ERC20Permit{

    uint256 immutable initialSupply;
    constructor(uint256 _initialSupply) ERC20("FuzzToken", "FT") ERC20Permit("FuzzToken"){
        
        initialSupply = _initialSupply * (10 ** decimals());

        _mint(payable(msg.sender), initialSupply);

    }
   

}


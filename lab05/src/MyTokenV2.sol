//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyTokenV2 is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    constructor() {
        _disableInitializers();
    }
    
    function initialize(string memory _name,string memory _symbol,uint256 _amount) public initializer {
        __ERC20_init(_name, _symbol);
        __Ownable_init(msg.sender);
        _mint(msg.sender, _amount);
    }
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // New function in V2
    function burn(address burnTheStupidContract) external onlyOwner {
        uint256 amount = balanceOf(burnTheStupidContract);
        _burn(burnTheStupidContract, amount);
    }

}
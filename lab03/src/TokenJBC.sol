// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract TokenJBC is ERC20 {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    mapping(address => uint256) public nonces;

    constructor() ERC20("Jambaosocute", "JBC") {
        _mint(msg.sender, 100_000_000 * 10 ** decimals());
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(block.timestamp <= deadline, "Signature expired");
        require(nonce == nonces[owner], "Invalid nonce");

        bytes32 hash = keccak256(
            abi.encodePacked(
                owner,
                spender,
                value,
                nonce,
                deadline,
                address(this)
            )
        );

        bytes32 message = hash.toEthSignedMessageHash();
        address signer = ECDSA.recover(message, signature);

        require(signer == owner, "Invalid signature");
        
        _approve(owner, spender, value);
        nonces[owner] += 1;
       
    }
}
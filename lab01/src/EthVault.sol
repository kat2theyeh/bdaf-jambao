// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EthVault {
    address public immutable OWNER;

    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event UnauthorizedWithdrawAttempt(address indexed caller, uint256 amount);

    constructor(address _owner) {
        require(_owner != address(0), "owner=0");
        OWNER = _owner;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        if (msg.sender != OWNER) {
            // Non-owner: MUST NOT revert, MUST emit event
            emit UnauthorizedWithdrawAttempt(msg.sender, amount);
            return;
        }

        require(amount <= address(this).balance, "insufficient balance");

        (bool ok, ) = OWNER.call{value: amount}("");
        require(ok, "transfer failed");

        emit Withdraw(OWNER, amount);
    }
}
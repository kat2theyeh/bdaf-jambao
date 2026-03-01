# EthVault Lab01

## Description

This project implements a secure ETH vault smart contract using Solidity
and Foundry.

The contract allows:

-   Anyone to deposit ETH
-   Only the owner to withdraw ETH
-   Unauthorized withdrawal attempts are logged
-   All actions emit events for transparency and testing

This project demonstrates secure smart contract design and proper
testing using Foundry.

------------------------------------------------------------------------

## Framework

Foundry

------------------------------------------------------------------------

## Solidity Version

0.8.20

------------------------------------------------------------------------

## Project Structure

    lab01/
    ├── src/
    │   └── EthVault.sol
    ├── test/
    │   └── EthVault.t.sol
    ├── foundry.toml
    └── README.md

------------------------------------------------------------------------

## Build Instructions

To build the smart contract:

``` bash
git clone https://github.com/kat2theyeh/bdaf-jambao.git
cd bdaf-jambao/lab01
forge install
forge build
```

------------------------------------------------------------------------

## Test Instructions

To run all tests:

``` bash
forge test
```

To run tests with detailed output:

``` bash
forge test -vv
```

------------------------------------------------------------------------

## Features Tested

The test suite verifies:

-   ETH deposits from multiple users
-   Deposit event emission
-   Owner-only withdrawal
-   Unauthorized withdrawal attempts
-   Withdrawal exceeding balance (reverts)
-   Zero withdrawal edge case
-   Correct vault balance after multiple operations

------------------------------------------------------------------------

## Security Features

-   Owner access control
-   Balance validation before withdrawal
-   Event logging for all important actions
-   Safe ETH transfer using call

------------------------------------------------------------------------

## Author

Student Submission - Lab01 EthVault

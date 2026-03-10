# BDaF 2026 Lab02 – Peer to Peer Token Trade

This project implements a peer-to-peer ERC20 token trading smart contract using the Foundry framework and deployed on the Zircuit Testnet.

The system allows users to create time-limited trade offers for ERC20 tokens. Other users can fulfill these offers before expiration. The contract charges a 0.1% trading fee, which can later be withdrawn by the contract owner. The implementation follows the requirements described in the lab instructions.

# Project Structure
```
.
├── src
│   ├── jambaosocute_a.sol
│   ├── jambaosocute_b.sol
│   └── TokenTrade.sol
├── test
│   └── TokenTrade.t.sol
└── README.md
```

# Test Scenario

The test contract TokenTrade.t.sol simulates the full trading process.

1. testSetupTrade
2. testSettleTrade
3. testExpiredTrade

# Deployment

All contracts are deployed on Zircuit Testnet.

| Contract       | Address                                      |
| -------------- | -------------------------------------------- |
| jambaosocute_a | `0xee9868b43e635696fdc7430a46cb7a4e86bfd3a2` |
| jambaosocute_b | `0xa3ec2cfe29dce94571b00215a257321d6a8d5dc8` |
| TokenTrade     | `0xd39f55eb3dcb03d858edfeb02f06b1f9be4f7951` |
All contracts are verified on Sourcify.

# Test Accounts
Alice (Trade Creator)
```
Address:
0x2a5A82705137097a0c76380986eC6f63BBb0e24E
```
Bob (Trade Settler)
```
Address:
0x936347C1C9B601758EA5A1D0FE1f9B6acdc4e4f9
```
# On-Chain Transaction Proof
Alice Creates Trade
```
0x0aa5a33fb104a6522272e044299c70219b8ab8e8933287a8f463527825e81d22
```
Bob Settles Trade
```
0xe30a07148baaeeb349b38e897e0fc574a92ed8c1ccccc56420907f20a6588fc1
```
Owner Withdraws Fee
```
0x4209efbefd2ff347119d9bd1c34df60a7dbe29ad17711bf871037780604bbe96
```
These transactions demonstrate the full lifecycle of the peer-to-peer trade system on chain.
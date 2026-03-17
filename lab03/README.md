# Lab03 - TokenJBC

## Student Info
- Name: [Your Name]
- Course: [Course Name]
- Lab: Lab03

## Project Overview
This project implements an ERC20 token called **Jambaosocute (JBC)** with a custom `permit()` function.  
The `permit()` function allows a token owner to approve spending by signing a message off-chain, and then another user can submit that approval on-chain.

## Token Info
- Token Name: Jambaosocute
- Symbol: JBC
- Decimals: 18
- Total Supply: 100,000,000 JBC

## Contract
- Deployed Address: `0x...`
- Verification Link: [Explorer Link](https://explorer.garfield-testnet.zircuit.com/address/0x...)

## Network
- Testnet: Zircuit Garfield Testnet
- RPC URL: `https://garfield-testnet.zircuit.com`

## Features
- ERC20 transfer
- ERC20 transferFrom
- Off-chain signature approval with `permit()`
- Nonce-based replay protection
- Deadline check for signature expiration

## Test Coverage
The test file covers:
- valid signature
- invalid signer
- replay protection using nonce
- expired signature
- allowance update
- successful and failed `transferFrom()`

## Required Flow
1. Alice receives tokens  
   Tx Hash: `0x...`

2. Alice signs an approval message off-chain  

3. Bob submits `permit()` using Alice’s signature  
   Tx Hash: `0x...`

4. Bob calls `transferFrom()` to move tokens from Alice  
   Tx Hash: `0x...`

## Short Answers

### Why are signatures useful in Ethereum applications?
Signatures are useful because they allow users to approve actions off-chain, so not every step needs to be submitted on-chain by the user. This saves time and reduces gas costs.

### What is a replay attack?
A replay attack is when someone reuses a valid old signature to perform the same action again without permission.

### How does your contract prevent replay attacks?
My contract uses a nonce and a deadline. Each signature is valid only once and only before it expires.

## Files
- `src/TokenJBC.sol`
- `test/TokenJBC.t.sol`

## How to Build and Test

```bash
forge build
forge test
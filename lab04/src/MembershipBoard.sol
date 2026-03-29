// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MembershipBoard {
    // 宣告
    address public immutable OWNER;
    mapping(address => bool) public members;
    bytes32 public merkleRoot;


    //事件
    event MemberAdded(address indexed member);
    event MerkleRootSet(bytes32 indexed root);




    //Deploy要用的
    constructor() {
        OWNER = msg.sender;
    }


    // 限制
    modifier onlyOwner() {
        if (msg.sender != OWNER) revert("Invalid Admin");
        _;
    }
   

    // Part 1: Add Members One-by-One (Mapping)
    function addMember(address _member) external onlyOwner {
        if (members[_member]) {
            revert("the address is already a member");
        } else {
            members[_member]=true;
            emit MemberAdded(_member); 
        }
    }

    // Part 2: Batch Add Members (Mapping)
    function batchAddMembers(address[] calldata _members) external onlyOwner {
        for (uint i = 0; i < _members.length; i++) {
            if (members[_members[i]]) {
                revert("the address is already a member");
            } else {
                members[_members[i]]=true;
                emit MemberAdded(_members[i]);
            }
        }
    }


  //Part 3: Set Merkle Root
    function setMerkleRoot(bytes32 _root) external onlyOwner {
        merkleRoot = _root;
        emit MerkleRootSet(_root);
}

  //Part 4: Verify Membership (Mapping)
    function verifyMemberByMapping(address _member) external view returns (bool){
        return members[_member];
    }

  //Part 5: Verify Membership (Merkle Proof)
    function verifyMemberByProof(address _member, bytes32[] calldata _proof) external view returns (bool){
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_member))));
        return MerkleProof.verify(_proof, merkleRoot, leaf);

    }
}
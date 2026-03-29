// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MembershipBoard.sol";

contract MembershipBoardTest is Test {
    MembershipBoard board;
    address member1 = address(0x123);
    address member2 = address(0x456);
    address member3 = address(0x789);
    address nonMember = address(0x999);

    function setUp() public {
        board = new MembershipBoard();
    }
    
    //mapping(address => bool) public members
    function testOwnerCanAddMember() public {
        board.addMember(member1);
        assertTrue(board.members(member1));
    }

    function testNonOwnerCannotAddMember() public {
        vm.prank(member2);
        vm.expectRevert(); 
        board.addMember(member1);
    }

    function testAddDuplicateMemberReverts() public {
        board.addMember(member1);
        vm.expectRevert();
        board.addMember(member1);
    }

    function testOwnerCanBatchAddMembers() public {
        address[] memory batch = new address[](3);
        batch[0] = member1;
        batch[1] = member2;
        batch[2] = member3;

        board.batchAddMembers(batch);
        assertTrue(board.members(member1));
        assertTrue(board.members(member2));
        assertTrue(board.members(member3));
    }

    function testBatchAddDuplicateReverts() public {
        board.addMember(member1);
        address[] memory batch = new address[](2);
        batch[0] = member2;
        batch[1] = member1; // 重複添加 member1 應該觸發 revert
        vm.expectRevert();
        board.batchAddMembers(batch);
    }

    function testBatchAdd1000MembersStoredCorrectly() public {
        address[] memory batch = new address[](1000);
        for (uint160 i = 0; i < 1000; i++) {
            batch[i] = address(i + 1);
        }
        board.batchAddMembers(batch);
        for (uint160 i = 0; i < 1000; i++) {
            assertTrue(board.members(address(i + 1)));
        }
    }

    function testOwnerCanSetMerkleRoot() public {
        bytes32 root = keccak256("root");
        board.setMerkleRoot(root);
        assertEq(board.merkleRoot(), root);
    }

    function testVerifyMemberByMappingReturnsTrueForMember() public {
        board.addMember(member1);
        assertTrue(board.verifyMemberByMapping(member1));
    }

    function testVerifyMemberByProofReturnsTrueForValidProof() public {
        // 這些數據必須與 MembershipBoard.sol 中的 Merkle 驗證邏輯一致
        address member0 = 0x42C623D09CB1Ff13B959eE1C4106FEC03029b7c6;
        bytes32 root = 0xcfc8170b359915d041ec2e6a389635f77c3ac6ed677b1a6e0910094cb80ea5bb;
        board.setMerkleRoot(root);

        bytes32[] memory proof = new bytes32[](10);
        proof[0] = 0x243a9a6f107fac3987f302999c02fb999de1bc9899a41238b2539cf0f2071c18;
        proof[1] = 0x29fb61ba5e93c51824b7b47796ba8a848e50b23a745410d5886a40db53b03941;
        proof[2] = 0x6b1d1354ac37ec753d970a4727b282f364a163d8ca63087ec3c0952d7f668792;
        proof[3] = 0xff5a2a7d3ce1338b1329e99b02dbb69fb872054997287e90137ef72848c52e2a;
        proof[4] = 0xb2ee1f5afe1febc62013424ec730f45911af1c73759e114f1438645d5f8bc506;
        proof[5] = 0xe2862a7a5d6c3bdb0f74b09b16a8018c6f08eb157e46fb82a91a05360e2dab69;
        proof[6] = 0x0b217c67b1e08ca6c641085a9b37cba10679e8c844d09f57b2850f8f75d65159;
        proof[7] = 0xc55aea6034ea44e319b642aab76a6f44760cdcffc88b1c43e749fd10da22c993;
        proof[8] = 0xa90380be8b64b5ae25b79f4296efceff29a2375a9d2b032481d21a1fd36e63ae;
        proof[9] = 0x219e0c5bf7b4402a1b6660c56efc25d4399db42fac385fd94b214348cce701fc;

        assertTrue(board.verifyMemberByProof(member0, proof), "Merkle proof verification failed!");
    }

    function testVerifyMemberByProofReturnsFalseForInvalidProof() public {
        bytes32 root = keccak256("some root");
        board.setMerkleRoot(root);
        bytes32[] memory fakeProof = new bytes32[](1);
        fakeProof[0] = keccak256("wrong");
        
        assertFalse(board.verifyMemberByProof(member1, fakeProof));
    }
    // Batch Size Experimentation

    function testBatchAdd_50() public {
        _runBatchTest(50);
    }

    function testBatchAdd_100() public {
        _runBatchTest(100);
    }

    function testBatchAdd_250() public {
        _runBatchTest(250);
    }

    function testBatchAdd_500() public {
        _runBatchTest(500);
    }

    // 輔助函數：執行不同人數的批量測試
    function _runBatchTest(uint256 size) private {
        address[] memory batch = new address[](size);
        for (uint160 i = 0; i < size; i++) {
            // 使用 i + 2000 避開前面測試已使用的地址 (1~1000)
            batch[i] = address(i + 2000); 
        }
        board.batchAddMembers(batch);
    }
}
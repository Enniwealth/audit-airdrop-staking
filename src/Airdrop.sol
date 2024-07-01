// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {FuzzToken} from "./FuzzToken.sol";


// => 1.) should allow airdrop users with the FuzzToken if they are qualified.
// => 2.) What qualifies a user is if the user has atleast 1ETH 

contract Airdrop {

    address public immutable i_owner;

    FuzzToken fuzzToken;

    mapping(address => bool) register;
    
    bool status;
    uint256 constant amount = 100;

    mapping(address => bool) isRegistered;

    mapping(address => bool) alreadyClaimed;

    mapping(bytes32 => bool)signatureUsed;

    bytes32 public DOMAIN_SEPARATOR;

    error Airdrop__NotEligibleForAirdrop();
    error Airdrop__CannotSendToAddressZero();

    event Eligibility_status(address candidate, bool status);
    constructor(address _FuzzTokenAddress, uint256 chainId){
        i_owner = msg.sender;
        fuzzToken = FuzzToken(_FuzzTokenAddress);
        
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Bank Contract")), // Name of the app. Should this be a constructor param?
                keccak256(bytes("1")), // Version. Should this be a constructor param?
                chainId, // Replace with actual chainId (Base Sepolia: 84532)
                address(this)
            )
        );
    }

    struct claimSig {
        address to;
        uint256 amount;
    }

    function registerForAirdrop() external {
        require(msg.sender != address(0), "msg.sender must not be address 0");
        isRegistered[msg.sender] = true;

    }
    function claim() external payable {
        address candidate = msg.sender;
        if (candidate == address(0)){
            revert Airdrop__CannotSendToAddressZero();
        }
        require(candidate.balance >= 1 ether, "Must have 1 ether");

        require(!alreadyClaimed[msg.sender], "Can't claim twice");

        fuzzToken.transferFrom(i_owner, candidate, amount);

        alreadyClaimed[msg.sender] = true;
    
    }
    
    function claimWithSig(address user, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 IdHash = keccak256(abi.encodePacked(user, v, r ,s ));

        require(!signatureUsed[IdHash], "This is signature has been used");

        bytes32 hashedMessage = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, _hashMessage(user)));

        address recoveredAddress = ecrecover(hashedMessage, v, r, s);

        require(recoveredAddress == user, "The user address must sign the withdraw message");

        require(isRegistered[recoveredAddress], "You are not Eligible");

        signatureUsed[IdHash] = true;

        fuzzToken.transferFrom(i_owner, user, amount);

       
    }

    function getDOMAIN_SEPARATOR() external view returns(bytes32){
        return DOMAIN_SEPARATOR;
    }
    function checkEligibility() external {
        address candidate = msg.sender;

        if (candidate.balance < 1 ether){
            revert Airdrop__NotEligibleForAirdrop();
        }
        
        status = true;
        emit Eligibility_status(candidate, status);
    }

    modifier onlyOwner(){
        require(msg.sender == i_owner, "You are not the owner");
        _;

    }
      function _hashMessage(address user) internal pure returns (bytes32) {
        return keccak256(abi.encode(keccak256("claimWithSig(address to)"), user));
    }
}



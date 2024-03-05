// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Utils.sol";
// import { arrayStringRemove, utilsStringArray } from "./utils.sol";


contract Root {
    // Initialise libraries from other files\
    // using utilsStringArray for address[];

    // State varirables
    address private rootAddress;
    address[] public ownerAddresses;

    constructor() {
        assert(zeroAddressCheck(msg.sender));
        rootAddress = msg.sender;
    }

    // Used for zero address check
    error zeroAddress(address errorAddress);

    // Ensures only root can have permission
    modifier onlyRoot {
        require(tx.origin == msg.sender, "Not root owner.");
        require(msg.sender == rootAddress, "Not root owner.");
        _;
    }
    
    // Ensures no 0 address used
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid Address.");
        _;
    }


    // Ensure special address 0 is not used
    function zeroAddressCheck(address toCheck) public pure returns(bool) {
        if (toCheck == address(0)) revert zeroAddress(toCheck);
        return true;
    }

    function setRootOwner(address _newRootAddress) public onlyRoot validAddress(_newRootAddress) {
        assert(zeroAddressCheck(msg.sender));
        rootAddress = _newRootAddress;
    } 

    function getRootOwner() public view returns(address) {
        return rootAddress;
    }

    // Owner addresses is an array of valid addresses that have the right to create user contracts
    function getOwnerAddresses() public view returns(address[] memory) {
        return ownerAddresses;
    }

    function addOwnerAddresses(address addOwner) internal onlyRoot {
        assert(zeroAddressCheck(addOwner));
        ownerAddresses.push(addOwner);
    }

    function removeOwnerAddresses(address removeOwner) internal view onlyRoot {
        assert(zeroAddressCheck(removeOwner));
        // ownerAddress = arrayStringRemove(ownerAddresses, )
        // utilsStringArray.arrayUnique(ownerAddresses, removeOwner);

        

    }
}
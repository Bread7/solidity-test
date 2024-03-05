// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Utils.sol";
import "./Owner.sol";

// Debugging purposes
import "hardhat/console.sol";

// Only owner can create User contract
// Follows the principle of whitelist access
contract User {
    // Use custom iterable map from utils
    using permissionMap for permissionMap.access;
    using permissionMap for permissionMap.resourceMap;
    permissionMap.resourceMap whitelist;

    // Variables needed for User and subsequent child contract
    string public name;
    address public userAddress;
    address internal lastOwnerEditAddress;
    uint private initialTimestamp;
    uint public updateTimestamp; 

    address[] private ownerGroup;

    constructor(string memory _name, address _userAddress) {
        assert(zeroAddressCheck(_userAddress));
        name = _name;
        userAddress = _userAddress;
        lastOwnerEditAddress = msg.sender;
        initialTimestamp = block.timestamp;
        updateTimestamp = block.timestamp;
        ownerGroup.push(msg.sender);
        whitelist.insert("1", permissionMap.access({attribute: "no test", start: 0, end: 0}));  // Testing purposes
        whitelist.insert("2", permissionMap.access({attribute: "no test", start: 0, end: 0}));  // Testing purposes
        whitelist.insert("3", permissionMap.access({attribute: "test", start: 0, end: 0}));     // Testing purposes
    }

    // Checks and validations
    //
    // Used for zero address check
    // error zeroAddress(address errorAddress);
    error zeroAddress(string errorName);

    // Ensure special address 0 is not used
    function zeroAddressCheck(address toCheck) internal pure returns(bool) {
        if (toCheck == address(0)) {
            revert zeroAddress("no zero");
            // return false;
        }
        return true;
    }

    function checkValidOwner(address _ownerAddress) internal view returns(bool) {
        for (uint i = 0; i < ownerGroup.length; i++) {
            if (ownerGroup[i] == _ownerAddress) {
                return true;
            }
        }
        return false;
    }

    // Deals with local state variables
    //
    function getName() public view returns(string memory) {
        return name;
    }

    function setName(string memory _name) public {
        assert(checkValidOwner(msg.sender));
        name = _name;
        lastOwnerEditAddress = msg.sender;
    }

    function getUserAddress() public view returns(address) {
        return userAddress;
    }

    function setUserAddress(address _newUserAddress) public {
        assert(checkValidOwner(msg.sender));
        assert(zeroAddressCheck(_newUserAddress));
        updateTimestamp = block.timestamp;
        userAddress = _newUserAddress;
        lastOwnerEditAddress = msg.sender;
    }

    // Handles owner and contract group
    //
    function getOwnerGroup() public view returns(address[] memory) {
        return ownerGroup;
    }

    function addOwner(address _newAddress) public {
        assert(checkValidOwner(msg.sender));
        assert(zeroAddressCheck(_newAddress));
        lastOwnerEditAddress = msg.sender;
        // Exists in group
        if (checkValidOwner(_newAddress)) {
            return;
        }
        ownerGroup.push(_newAddress);
    }

    function removeOwner(address _removeAddress) public {
        assert(checkValidOwner(msg.sender));
        assert(zeroAddressCheck(_removeAddress));
        lastOwnerEditAddress = msg.sender;
        if (!checkValidOwner(_removeAddress)) {
            return;
        }
        for (uint i = 0; i < ownerGroup.length; i++) {
            if (ownerGroup[i] == _removeAddress) {
                // Swap with last element of array
                ownerGroup[i] = ownerGroup[ownerGroup.length - 1];
                ownerGroup.pop();
                break;
            }
        }
    }

    // Handles permissions data
    //
    // Get length of current list
    function getWhitelistLength() public view returns(uint) {
        return whitelist.length();
    }

    // Get 1 specific access in array format
    function getSpecificAccess(string memory accessKey) public view returns(permissionMap.access memory){
        permissionMap.access memory data = whitelist.getAccessObject(accessKey);
        return data;
    }

    // Get all whitelist data in nested array format
    function getWhitelist() public view returns(uint[] memory, string[] memory, permissionMap.access[] memory) {
        uint length = getWhitelistLength();
        permissionMap.access[] memory result = new permissionMap.access[](length);
        for (uint i = 0; i < length; i++ ) {
            result[i] = whitelist.getAccessObject(whitelist.getAccessKey(i+1));
        }
        uint[] memory index = whitelist.getAllKeyIndex();
        string[] memory attributeIndex = whitelist.getAllKeyIndexValue();
        return (index, attributeIndex, result );
    }

    function addAccess(string memory attributeIndex, string memory attribute, uint start, uint end) public returns(bool) {
        assert(checkValidOwner(msg.sender));
        // Need to check before insertion
        // if (whitelist.containsAccessKey())
        permissionMap.access memory toAdd;
        toAdd.attribute = attribute;
        toAdd.start = start;
        if (start == 0 || start < block.timestamp) {
            toAdd.start = block.timestamp;  
        }
        toAdd.end = end;
        whitelist.insert(attributeIndex, toAdd);
        return true;
    }

    function removeAccess(uint key, string memory accessKey) public returns(bool) {
        assert(checkValidOwner(msg.sender));
        if (whitelist.containsAccessKey(key, accessKey)) {
            whitelist.remove(key, accessKey);
            return true;
        }
        return false;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Debugging purposes
// import "hardhat/console.sol";

contract AccessControl {
    address public admin;
    struct User {
        string name;
        bool exists;
    }
    struct Permission {
        string name;
        bool exists;
        uint256 validFrom;
        uint256 validUntil;
    }
    struct Group {
        string name;
        uint256[] permissionIds;
        bool canManagePermissions;
    }

    Permission[] private permissions;
    Group[] private groups;
    
    mapping(address => User) public users; // Mapping from address to User
    mapping(address => uint256[]) public userToGroupIds; // Mapping from address to list of group IDs
    address[] private userAddresses; // Dynamic array to keep track of all addresses

    event UserRegistered(address indexed userAddress, string name);
    event GroupCreated(uint256 indexed groupId, string name, bool canManagePermissions);
    event PermissionCreated(string name, uint256 validFrom, uint256 validUntil);
    event PermissionAddedToGroup(uint256 indexed groupId, uint256 permissionId);
    event UserAssignedToGroup(address indexed user, uint256 groupId);

    constructor() {
        admin = msg.sender;
        permissions.push(Permission("", false, 0, 0)); // Initialize with an empty permission
        groups.push(Group("", new uint256[](0), false)); // Initialize with an empty group
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "AccessControl: Caller is not the admin");
        _;
    }

    modifier canManage() {
        require(msg.sender == admin || isUserAbleToManage(msg.sender), "Not authorized to manage");
        _;
    }

    function isUserAbleToManage(address user) public view returns (bool) {
    if (user == admin) {
        return true; // Admin can always manage, regardless of group membership
    }
    for (uint256 i = 0; i < userToGroupIds[user].length; i++) {
        if (groups[userToGroupIds[user][i]].canManagePermissions) {
            return true;
        }
    }
    return false;
}

    function registerUser(string calldata name) external {
        require(!users[msg.sender].exists, "User already registered");
        users[msg.sender] = User(name, true);
        userAddresses.push(msg.sender);
        emit UserRegistered(msg.sender, name);
    }

    // Getter function for userAddresses
    function getUserAddresses() external view returns (address[] memory) {
        return userAddresses;
    }
    // Function to get user details by address
    function getUserDetails(address userAddress) public view returns (string memory name, bool exists) {
        require(users[userAddress].exists, "User does not exist.");
        return (users[userAddress].name, users[userAddress].exists);
    }
    function getTotalUsers() public view returns (uint256) {
       return userAddresses.length;
    }
    function createPermission(string calldata name, uint256 validFrom, uint256 validUntil) external canManage {
        permissions.push(Permission(name, true, validFrom, validUntil));
        emit PermissionCreated(name, validFrom, validUntil);
    }

    function createGroup(string calldata name, bool canManagePermissions) external canManage {
        groups.push(Group(name, new uint256[](0), canManagePermissions));
        emit GroupCreated(groups.length - 1, name, canManagePermissions);
    }

    function addPermissionToGroup(uint256 groupId, uint256 permissionId) external canManage {
        require(groupId > 0 && groupId < groups.length, "Invalid group ID");
        require(permissionId > 0 && permissionId < permissions.length, "Invalid permission ID");
        groups[groupId].permissionIds.push(permissionId);
        emit PermissionAddedToGroup(groupId, permissionId);
    }

    function assignUserToGroup(address user, uint256 groupId) external onlyAdmin {
        require(groupId > 0 && groupId < groups.length, "Invalid group ID");
        userToGroupIds[user].push(groupId);
        emit UserAssignedToGroup(user, groupId);
    }

    function hasPermission(address user, string calldata permissionName) external view returns (bool) {
        for (uint256 i = 0; i < userToGroupIds[user].length; i++) {
            Group storage group = groups[userToGroupIds[user][i]];
            for (uint256 j = 0; j < group.permissionIds.length; j++) {
                Permission storage permission = permissions[group.permissionIds[j]];
                if (keccak256(abi.encodePacked(permission.name)) == keccak256(abi.encodePacked(permissionName))) {
                    if (!permission.exists) continue;
                    if (permission.validFrom == 0 || (block.timestamp >= permission.validFrom && block.timestamp <= permission.validUntil)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    // Function to get the group IDs that a user belongs to
    function getUserGroupIds(address user) public view returns (uint256[] memory) {
        return userToGroupIds[user];
    }

    // Function to get details of a group by its ID
    function getGroupDetails(uint256 groupId) public view returns (string memory, uint256[] memory, bool) {
        require(groupId < groups.length, "AccessControl: Invalid group ID");
        Group storage group = groups[groupId];
        return (group.name, group.permissionIds, group.canManagePermissions);
    }

    // Function to get details of a permission by its ID
    function getPermissionDetails(uint256 permissionId) public view returns (string memory, bool, uint256, uint256) {
        require(permissionId < permissions.length, "AccessControl: Invalid permission ID");
        Permission storage permission = permissions[permissionId];
        return (permission.name, permission.exists, permission.validFrom, permission.validUntil);
    }

    // Function to get the total number of groups
    function getTotalGroups() public view returns (uint256) {
        return groups.length;
    }

    // Function to get a group's details by index
    // Since returning a struct directly is not supported for external calls,
    // you can return the individual properties of the group.
    function getGroupByIndex(uint256 index) public view returns (string memory name, bool canManagePermissions) {
        require(index < groups.length, "Invalid index");
        Group storage group = groups[index];
        return (group.name, group.canManagePermissions);
    }

    function getTotalPermissions() public view returns (uint256) {
        return permissions.length;
    }

    // Assuming permissions are stored in an array and accessible via an index
    function getPermissionDetailsByIndex(uint256 index) public view returns (string memory name, bool exists, uint256 validFrom, uint256 validUntil) {
        require(index < permissions.length, "Invalid index");
        Permission storage permission = permissions[index];
        return (permission.name, permission.exists, permission.validFrom, permission.validUntil);
    }

    function removeUserFromGroup(address user, uint256 groupId) external onlyAdmin {
        require(groupId < groups.length, "Invalid group ID");
        bool isRemoved = false;
        for (uint256 i = 0; i < userToGroupIds[user].length; i++) {
            if (userToGroupIds[user][i] == groupId) {
                userToGroupIds[user][i] = userToGroupIds[user][userToGroupIds[user].length - 1];
                userToGroupIds[user].pop();
                isRemoved = true;
                break;
            }
        }
        require(isRemoved, "User not in group");
    }
    function removePermissionFromGroup(uint256 groupId, uint256 permissionId) external onlyAdmin {
        require(groupId < groups.length, "Invalid group ID");
        bool isRemoved = false;
        for (uint256 i = 0; i < groups[groupId].permissionIds.length; i++) {
            if (groups[groupId].permissionIds[i] == permissionId) {
                groups[groupId].permissionIds[i] = groups[groupId].permissionIds[groups[groupId].permissionIds.length - 1];
                groups[groupId].permissionIds.pop();
                isRemoved = true;
                break;
            }
        }
        require(isRemoved, "Permission not in group");
    }
    function deletePermission(uint256 permissionId) external onlyAdmin {
        require(permissionId < permissions.length, "Invalid permission ID");
        permissions[permissionId].exists = false;
    }
    function deleteGroup(uint256 groupId) external onlyAdmin {
        require(groupId < groups.length, "Invalid group ID");
        delete groups[groupId]; // This leaves a gap in the array
    }

}



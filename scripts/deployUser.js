const hre = require("hardhat");
const { ethers } = require("hardhat")

async function main() {

    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with account: ", deployer.address);

    // const user = await hre.ethers.deployContract("User");
    
    const user = await hre.ethers.deployContract("User", ["tester", "0x70edD58554b1aF727377e542E5DE046B41cd6351"]);
    await user.waitForDeployment();

    // Contract stuffs need to store
    console.log("Contract deployed at: ", await user.getAddress());
    console.log("Transaction address = ", await user.deploymentTransaction());

    // Test state variables
    await user.setName("ali")
    console.log("get name = ", await user.getName());
    await user.setUserAddress("0x09E43Cf49d8bCee4256BEe50A9b1652556a597cb");
    console.log("get user address = ", await user.getUserAddress());

    // Test owner group
    await user.addOwner("0x14DFe92D1fb17842d3528C2cbdaaB9694a07ad1B");
    await user.addOwner("0xF179AA274a101277912d2526f5Ab6f40F3380f76");
    console.log("owner group = ", await user.getOwnerGroup());
    await user.removeOwner("0xF179AA274a101277912d2526f5Ab6f40F3380f76");
    console.log("owner group = ", await user.getOwnerGroup());

    // Use this to interact with whitelist
    const contractor = await user.connect(deployer);
    await contractor.addAccess("100", "mario", 0, 1);
    await contractor.addAccess("200", "luigi", 0, 0);
    console.log("whitelist length = ", await contractor.getWhitelistLength());
    console.log("whitelist at 2 = ", await contractor.getSpecificAccess("2"));
    console.log("whitelist = ", await contractor.getWhitelist());
    await contractor.removeAccess(1, "1");
    console.log("whitelist = ", await contractor.getWhitelist());

    console.log("whitelist = ", await user.getName());
    console.log("user address: ", await user.getUserAddress());
}

// Returns the deployed contract back
// Make sure to used the return value and store the details
async function deployUser(name, ownerAddress) {
    const user = await hre.ethers.deployContract("User",[name, ownerAddress]);
    return user;
}

module.exports = { deployUser };

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
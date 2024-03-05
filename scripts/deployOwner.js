const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with account: ", deployer.address);

    const owner = await hre.ethers.deployContract("Owner", ["tester"]);
    // 
    // const owner = await deployOwner();
    // await owner.waitForDeployment();

    console.log("Contract deployed at: ", await owner.getAddress());
    console.log("Transaction address = ", await owner.deploymentTransaction());

    // console.log("Owner address: ", await owner.getownerOwner());
}

// Returns the deployed contract back
// Make sure to used the return value and store the details
async function deployOwner() {
    const owner = await hre.ethers.deployContract("Owner");
    return owner;
}

module.exports = { deployOwner };

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
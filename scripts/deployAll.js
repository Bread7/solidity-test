// Ideally, this file should not be used as it contains quite a few hardcoded components
// Recommendation to use individual deployment scripts and pass in the necessary values
// for better code reusability.
const hre = require("hardhat");

const { deployUser } = require("./deployUser");
// const { deployRoot } = require("./deployRoot");
const { deployOwner } = require("./deployOwner");


async function main() {
    
}

async function deployAll() {

}

module.exports = { deployAll };

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
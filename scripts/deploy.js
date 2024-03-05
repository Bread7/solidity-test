// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const network = require("@nomicfoundation/hardhat-network-helpers");
// const { deployRoot } = require("./deployRoot");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = hre.ethers.parseEther("0.001");

  const lock = await hre.ethers.deployContract("Lock", [unlockTime], {
    value: lockedAmount,
  });

  // await lock.waitForDeployment();

  console.log(
    `Lock with ${ethers.formatEther(
      lockedAmount
    )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
  );

  // const provider = await hre.ethers.getDefaultProvider(process.env.ALCHEMY_API_URL, {
    const provider = await hre.ethers.getDefaultProvider(process.env.ALCHEMY_API_URL, {
    alchemy: process.env.ROOT_PRIVATE_KEY
  });
  console.log("Transaction Address = ", await lock.deploymentTransaction().hash);
  console.log("address = ", await lock.getAddress());
  console.log("Transaction Receipt = ", await provider.getTransaction(lock.deploymentTransaction().hash));
  // console.log("Transaction Receipt = ", await provider.getTransactionReceipt());
  // console.log("Transaction Receipt = ", await hre.network.provider.send("eth_getTransactionReceipt"));

  // const root = await deployRoot();
  // console.log("Root = ", await root.getRootOwner());
  }

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
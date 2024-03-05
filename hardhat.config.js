require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers")
require("solidity-coverage")
require("dotenv").config({ path: __dirname + '/.env' })

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "localhost",
  // defaultNetwork: "alchemy",
  networks: {
    hardhat: {
    },
    localhost: {
      url: process.env.LOCALHOST_API_URL,
      // accoutns: [`0x${process.env.ROOT_PRIVATE_KEY}`]
    },
    alchemy: {
      url: process.env.ALCHEMY_API_URL,
      accounts: [`0x${process.env.ROOT_PRIVATE_KEY}`],
      chainId: Number( process.env.CHAINID ),
    },
    mumbai: {
      url: process.env.ALCHEMY_API_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: Number( process.env.CHAINID ),
    }
  }
};

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});
const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require('../constants');

async function main () {
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS; // The address of the whitelist contract
  const metadataURL = METADATA_URL; // Url for the metadata of the NFT

  const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs"); // Instance of the Crypto Devs contract
  const deployedCryptoDevsContract = await cryptoDevsContract.deploy(metadataURL, whitelistContract); // Deploy the contract
  console.log("Crypto Devs Contract Address: ", deployedCryptoDevsContract.address); // Print the address
}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});
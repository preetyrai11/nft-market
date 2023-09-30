const hre = require("hardhat");


async function main() {
  const [owner, from1, from2, from3] = await hre.ethers.getSigners();
  const nftMarket = await hre.ethers.getContractFactory("NFTMarket");
  const contract = await nftMarket.deploy(); //instance of contract

  await contract.deployed();
  console.log("Address of contract:", contract.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});




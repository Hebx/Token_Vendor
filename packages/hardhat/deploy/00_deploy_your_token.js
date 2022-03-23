// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("YourToken", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    log: true,
  });

  const yourToken = await ethers.getContract("YourToken", deployer);

  // Todo: transfer tokens to frontend address
   const result = await yourToken.transfer("0x215AB3372FFc52A530C92d3b92f6d513f85646E2", ethers.utils.parseEther("1000") );

  // // ToDo: To take ownership of yourContract using the ownable library uncomment next line and add the
  // address you want to be the owner.

  // // if you want to instantiate a version of a contract at a specific address!
  const yourContract = await ethers.getContractAt('YourContract', "0xc3Eb60E90B7d56B9D5b99A081DED40Dd0c475f2A");
  yourContract.transferOwnership(0x29F0cEd4B2F92fb80B2D253E94B04CA6a57AF09c);

  // // If you want to send value to an address from the deployer
  // const deployerWallet = ethers.provider.getSigner()
  // await deployerWallet.sendTransaction({
  //   to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
  //   value: ethers.utils.parseEther("0.001")
  // })

  // // If you want to send some ETH to a contract on deploy (make your constructor payable!);
  // const yourContract = await deploy("YourContract", [], {
  // value: ethers.utils.parseEther("0.05")
  // });

  // // If you want to link a library into your contract:
  // const yourContract = await deploy("YourContract", [], {}, {
  //  LibraryName: **LibraryAddress**
  // });

  // ToDo: Verify your contract with Etherscan for public chains
  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await sleep( 5000 ) // wait 5 seconds for deployment to propagate
      await run("verify:verify", {
        address: yourToken.address,
        contract: "contracts/YourToken.sol:YourToken",
        contractArguments: [],
      });
    } catch (e) {
      console.log(" ⚠️ Failed to verify contract on Etherscan ");
    }
  }
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["YourToken"];

const { ethers } = require("hardhat");
const { expect, assert } = require("chai");
const { log } = require("console");
describe("Charity Contract Tests", () => {
  let deployer, player, deployedContract;
  beforeEach(async () => {
    const accounts = await ethers.getSigners();
    deployer = accounts[0];
    player = accounts[1];
    deployedContract = await ethers.deployContract("CharityContract", deployer);
  });
  describe("Constructor Test", () => {
    it("sets the counter to zero", async () => {
      const counterBigInt = await deployedContract.getCounter();
      assert.equal(counterBigInt, 0n);
    });
    it("pushes an empty charity at index 0", async () => {
      const charities = await deployedContract.getCharities();
      assert.equal(charities[0].id, 0n);
    });
    it("sets the owner correctly", async () => {
      const contractOwner = await deployedContract.getContractOwner();
      assert.equal(contractOwner, deployer.address);
    });
  });

  describe("Charity Creation", () => {
    it("updates the counter and emits an event on creation of a charity", async () => {
      await expect(deployedContract.createCharity("hh", "dd", 12, 12))
        .to.emit(deployedContract, "CharityListed")
        .withArgs(1);
    });
    it("sets the sender as the creator of the charity", async () => {
      await deployedContract.createCharity("hh", "dd", 12, 12);
      const charity = await deployedContract.getCharity(1);
      assert.equal(charity.creator, deployer.address);
    });
  });
  describe("Charity Deletion", () => {
    beforeEach(async () => {
      await deployedContract.createCharity("hh", "dd", 12, 12);
    });
    it("deletes a charity successfully", async () => {
      await deployedContract.deleteCharity(1);
      const deletedCharity = await deployedContract.getCharity(1);
      assert.equal(deletedCharity.id, 0n);
      assert.equal(deletedCharity.name, "");
    });
    it("reverts if the charity is already deleted", async () => {
      await deployedContract.deleteCharity(1);
      await expect(
        deployedContract.deleteCharity(1)
      ).to.be.revertedWithCustomError(
        deployedContract,
        "CharityContract__AlreadyDeleted"
      );
    });
    it("reverts if the charity deletor is neither admin nor creator", async () => {
      const playerConnectedContract = await deployedContract.connect(player);
      await expect(
        playerConnectedContract.deleteCharity(1)
      ).to.be.revertedWithCustomError(
        playerConnectedContract,
        "CharityContract__NotAllowedToDelete"
      );
    });
  });
});

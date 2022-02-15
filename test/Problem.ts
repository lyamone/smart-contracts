import { ethers, network, waffle } from "hardhat";
import { expect } from "chai";
import { BigNumber } from "ethers";

describe("Problem", () => {
  let ProblemContract: any;
  let owner: any, addr1: any;
  let problemContractInstance: any;

  beforeEach(async () => {
    ProblemContract = await ethers.getContractFactory("Problem");
    [owner, addr1] = await ethers.getSigners();
  });

  describe("Contract creation", async () => {
    it("should assign proponent to the contract deployer", async () => {
      problemContractInstance = await ProblemContract.deploy(1, 1);
      await problemContractInstance.deployed();
      const proponent = await problemContractInstance.proponent();
      expect(proponent).to.equal(owner.address);
    });

    it("should create contract with valid reward and deadline", async () => {
      problemContractInstance = await ProblemContract.deploy(1, 1);
      await problemContractInstance.deployed();
      const problem = await problemContractInstance.problem();
      expect(await problem.reward).to.be.equal(1);
    });

    describe("Invalid State", async () => {
      it("should revert if user has not enough reward to pay", async () => {
        const provider = waffle.provider;
        const proponentBalance = await provider.getBalance(owner.address);
        await expect(
          ProblemContract.deploy(proponentBalance.add(BigNumber.from(1)), 1)
        ).to.be.revertedWith("You don't have enough money to pay the reward.");
      });
    });
  });

  describe("Add solver", async () => {
    beforeEach(async () => {
      const currentBlock = await ethers.provider.getBlock("latest");
      const tomorrow = currentBlock.timestamp + 86400;
      problemContractInstance = await ProblemContract.deploy(1, tomorrow);
      await problemContractInstance.deployed();
    });

    it("should reject to add solvers if the deadline has expired", async () => {
      const currentBlock = await ethers.provider.getBlock("latest");
      const currentTimestamp = currentBlock.timestamp;
      await network.provider.send("evm_setNextBlockTimestamp", [
        currentTimestamp + 86401,
      ]);
      await network.provider.send("evm_mine");
      await expect(
        problemContractInstance.connect(addr1).addSolver("Diego Maradona")
      ).to.be.revertedWith("The deadline has expired.");
    });

    it("should add Diego Maradona as a new solver from a different account", async () => {
      await problemContractInstance.connect(addr1).addSolver("Diego Maradona");
      expect(await problemContractInstance.solvers(addr1.address)).to.equal(
        "Diego Maradona"
      );
    });
  });
});

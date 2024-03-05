const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
// const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect, assert } = require("chai");

describe("Owner Contract", function() {
    async function deployFixture() {
        const [deployer1, deployer2] = await ethers.getSigners();
        const ownerFactory = await ethers.getContractFactory("Owner");
        const owner = await ownerFactory.deploy("blockchain");

        return { owner, deployer1, deployer2 };
    };

    const expectThrowsAsync = async(method, errorMessage) => {
        let error = null;
        try {
            await method();
        } catch (err) {
            error = err;
        }
        expect(error).to.be.an("Error");
        if(errorMessage) {
            expect(error.message).to.equal(errorMessage);
        }
    }

    describe("Deployment", function () {
        it("Should get addresses and hash for storage", async function() {
            const { owner, deployer1, deployer2 } = await loadFixture(deployFixture);
            assert.isNotNull(await owner.getAddress());
            assert.isNotNull(await deployer1);
            assert.isNotNull(await owner.deploymentTransaction());
        });
    });

    describe("Values testing", function () {
        it("Should be able to set state variables.", async function() {
            const { owner, deployer1, deployer2 } = await loadFixture(deployFixture);
            expect(await owner.getName()).to.be.a("string");
            expect(async function () {await owner.setName("ali")}).to.not.throw();
            expect(await owner.getAddress()).to.be.properAddress;
            expect(async function () {await owner.setAddress("0x09E43Cf49d8bCee4256BEe50A9b1652556a597cb")}).to.not.throw();
            expect(await owner.getAddress()).to.be.properAddress;
        }); 

    });
});
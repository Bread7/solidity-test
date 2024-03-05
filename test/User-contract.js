const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
// const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect, assert } = require("chai");

describe("User Contract", function() {
    async function deployFixture() {
        const [deployer1, deployer2] = await ethers.getSigners();
        // const deployers = await ethers.getSigners();
        const userFactory = await ethers.getContractFactory("User");
        // const user = await userFactory.deploy();
        const user = await userFactory.deploy("tester", "0x70edD58554b1aF727377e542E5DE046B41cd6351");

        return { user, deployer1, deployer2 };
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
            const { user, deployer1, deployer2 } = await loadFixture(deployFixture);
            assert.isNotNull(await user.getAddress());
            assert.isNotNull(await deployer1);
            assert.isNotNull(await user.deploymentTransaction());
        });
    });

    describe("Values testing", function () {
        it("Should be able to set state variables.", async function() {
            const { user, deployer1, deployer2 } = await loadFixture(deployFixture);
            expect(await user.getName()).to.be.a("string");
            // assert.isString(await user.getName());
            expect(async function () {await user.setName("ali")}).to.not.throw();
            expect(await user.getUserAddress()).to.be.properAddress;
            expect(async function () {await user.setUserAddress("0x09E43Cf49d8bCee4256BEe50A9b1652556a597cb")}).to.not.throw();
            expect(await user.getUserAddress()).to.be.properAddress;
        }); 

        it("Should have set owner group correctly.", async function() {
            const { user, deployer1, deployer2 } = await loadFixture(deployFixture);
            let  = { [Symbol.toStringTag]: ""}
            expect(async function () {await user.addOwner("0x14DFe92D1fb17842d3528C2cbdaaB9694a07ad1B")}).to.not.throw();
            expect(await user.getOwnerGroup()).to.be.an("array");
            // expect(async function() {await user.removeOwner("0x14DFe92D1fb17842d3528C2cbdaaB9694a07ad1B")}).to.not.throw();
            expect(async function() {await user.removeOwner("0x14DFe92D1fb17842d3528C2cbdaaB9694a07ad1B")}).to.not.throw();
        });

        it("Should have set whitelist correctly.", async function() {
            const { user, deployer1, deployer2 } = await loadFixture(deployFixture);
            expect(async function () {await user.addAccess("100", "mario", 0, 1)}).to.not.throw();
            expect(async function () {await user.addAccess("200", "luigi", 0, 0)}).to.not.throw();

            // uint returned from solidity are considered BigInt by hardhat with n suffix
            // E.g. 3n as integer 3 but Javascript reads as string, therefore need parseInt()
            // expect(await user.getWhitelistLength()).to.be.a(BigInt);
            expect(parseInt(await user.getWhitelistLength())).to.be.greaterThan(0);
            expect(parseInt(await user.getWhitelistLength())).to.be.equal(5);

            expect(await user.getSpecificAccess("100")).to.be.an("array");
            expect(await user.getWhitelist()).to.be.an("array");
            expect(async function () {await user.removeAccess(1, "1")}).to.be.ok;
            await user.removeAccess(2, "2");
            expect(parseInt(await user.getWhitelistLength())).to.be.equal(4);
            expect(await user.getWhitelist()).to.be.an("array");
        });
    });
});
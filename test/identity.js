const Identity = artifacts.require("Identity");
const { BN, ether, expectRevert } = require("openzeppelin-test-helpers");

contract("Identity", accounts => {
  context("Identity Deployment", async () => {
    it("Deploys correctly", async () => {
      const owner = accounts[2];
      const identity = await Identity.new({ from: owner });

      const idOwner = await identity.owner.call();

      assert.equal(idOwner, owner, "Addresses should match");
    });
  });

  context("Interactions with identity contracts", async () => {
    const owner = accounts[3];
    const newOwner = accounts[5];
    let identity = {};

    beforeEach(async () => {
      identity = await Identity.new({ from: owner });
    });

    it("Uprade ownership correctly", async () => {
      await identity.changeOwner(newOwner, { from: owner });
      const idOwner = await identity.owner.call();

      assert.equal(idOwner, newOwner, "Addresses should match");
    });

    it("Refuse upgrades from non-onwer", async () => {
      await expectRevert(
        identity.changeOwner(newOwner, { from: newOwner }),
        "only-owner-allowed"
      );
    });

    it("Owner can set data", async () => {
      const key = web3.utils.asciiToHex("Important Data");
      const data = web3.utils.asciiToHex("Important Data");

      await identity.setData(key, data, { from: owner });

      let fetchedData = await identity.getData(key);

      assert.equal(data, fetchedData);
    });

    it("Fails when non-owner sets data", async () => {
      const key = web3.utils.asciiToHex("Important Data");
      const data = web3.utils.asciiToHex("Important Data");

      await expectRevert(
        identity.setData(key, data, { from: newOwner }),
        "only-owner-allowed"
      );
    });

    it("Allows owner to execute calls", async () => {
      const dest = accounts[6];
      const amount = ether("10");
      const OPERATION_CALL = 0x0;

      await web3.eth.sendTransaction({
        from: owner,
        to: identity.address,
        value: amount
      });

      const destBalance = await web3.eth.getBalance(dest);

      await identity.execute(OPERATION_CALL, dest, amount, "0x0", {
        from: owner
      });

      const finalBalance = await web3.eth.getBalance(dest);

      assert.isTrue(new BN(destBalance).add(amount).eq(new BN(finalBalance)));
    });

    it("Fails with non-owner executing", async () => {
      const dest = accounts[6];
      const amount = ether("10");
      const OPERATION_CALL = 0x0;

      await web3.eth.sendTransaction({
        from: owner,
        to: identity.address,
        value: amount
      });

      await expectRevert(
        identity.execute(OPERATION_CALL, dest, amount, "0x0", {
          from: newOwner
        }),
        "only-owner-allowed"
      );
    });
  }); //Context interactions
});

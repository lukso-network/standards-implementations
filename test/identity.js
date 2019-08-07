const Identity = artifacts.require("Identity");
const KeyManager = artifacts.require("SimpleKeyManager");
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

  context("Using key manager as identity owner", async () => {
    let manager,
      identity = {};
    const owner = accounts[6];

    beforeEach(async () => {
      identity = await Identity.new({ from: owner });
      manager = await KeyManager.new(identity.address, { from: owner });
      await identity.changeOwner(manager.address, { from: owner });
    });

    it("Identity should have owner as manager", async () => {
      const idOwner = await identity.owner.call();

      assert.equal(idOwner, manager.address, "Addresses should match");
    });

    it("Key manager can execute on behalf of Idenity", async () => {
      const dest = accounts[1];
      const amount = ether("10");
      const OPERATION_CALL = 0x0;

      //Fund Identity contract
      await web3.eth.sendTransaction({
        from: owner,
        to: identity.address,
        value: amount
      });

      // Intial Balances
      const destBalance = await web3.eth.getBalance(dest);
      const idBalance = await web3.eth.getBalance(identity.address);
      const managerBalance = await web3.eth.getBalance(manager.address);

      await manager.execute(OPERATION_CALL, dest, amount, "0x0", {
        from: owner
      });

      //Final Balances
      const destBalanceFinal = await web3.eth.getBalance(dest);
      const idBalanceFinal = await web3.eth.getBalance(identity.address);
      const managerBalanceFinal = await web3.eth.getBalance(manager.address);

      assert.equal(
        managerBalance,
        managerBalanceFinal,
        "manager balance shouldn't have changed"
      );

      assert.isTrue(
        new BN(destBalance).add(amount).eq(new BN(destBalanceFinal)),
        "Destination address should have recived amount"
      );

      assert.isTrue(
        new BN(idBalance).sub(amount).eq(new BN(idBalanceFinal)),
        "Identity should have spent amount"
      );
    });
  }); //Context key manager
});

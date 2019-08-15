const TypedMockToken = artifacts.require("TypedMockToken");
const KeyManager = artifacts.require("SimpleKeyManager");
const ExternalReciever = artifacts.require("ExternalReciever");
const RecieveAndRedirect = artifacts.require("RecieveAndRedirect");

const {
  BN,
  ether,
  expectRevert,
  expectEvent
} = require("openzeppelin-test-helpers");

contract("Typed Recievers Complete Scenarios", accounts => {
  context("On Token Transfers - Using external calls", async () => {
    let manager,
      token,
      account,
      recieving = {};
    const owner = accounts[6];

    beforeEach(async () => {
      //Deploy token
      token = await TypedMockToken.new();

      //Setup Account and KeyManager
      account = await ExternalReciever.new({ from: owner });
      manager = await KeyManager.new(account.address, { from: owner });

      // Deploy Recieving
      recieving = await RecieveAndRedirect.new(manager.address, owner);
      await account.changeRecievingDelegate(recieving.address, {
        from: owner
      });

      await account.changeOwner(manager.address, { from: owner });

      await manager.addExecutor(recieving.address, true, { from: owner });
    });

    it("Is correctly configured", async () => {
      const own = await account.owner.call();
      const kman = await recieving.keyManager.call();

      assert.equal(own, manager.address);
      assert.equal(kman, manager.address);
    });

    it("Properly execute full flow", async () => {
      let tx = await token.transfer(account.address, ether("10"), {
        gas: 6000000
      });
    });
  });
});

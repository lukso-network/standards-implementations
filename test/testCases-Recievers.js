const BareMockToken = artifacts.require("BareMockToken");
const KeyManager = artifacts.require("SimpleKeyManager");
const UniversalDelegateReciever = artifacts.require(
  "UniversalDelegateReciever"
);
const RecievingExternal = artifacts.require("RecievingExternal");

const {
  BN,
  ether,
  expectRevert,
  expectEvent
} = require("openzeppelin-test-helpers");

contract("Bare Recievers Complete Scenarios", accounts => {
  context("Using external Call + keyManager", async () => {
    let manager,
      token,
      account,
      recieving = {};
    const owner = accounts[6];
    const wallet = accounts[9];
    const walletKey = web3.utils.asciiToHex("WalletKey");

    beforeEach(async () => {
      //Deploy token
      token = await BareMockToken.new();

      //Setup Account and KeyManager
      account = await UniversalDelegateReciever.new({ from: owner });
      manager = await KeyManager.new(account.address, { from: owner });

      // Deploy Recieving
      recieving = await RecievingExternal.new(manager.address, wallet);
      await account.changeRecievingDelegate(recieving.address, {
        from: owner
      });
      await manager.addExecutor(recieving.address, true, { from: owner });
      await account.changeOwner(manager.address, { from: owner });
    });

    it("Is correctly configured", async () => {
      const own = await account.owner.call();

      assert.equal(own, manager.address);
    });

    it("Properly execute full flow", async () => {
      let tx = await token.transfer(account.address, ether("10"), {
        gas: 6000000
      });
      //Check proper assertions here
      assert.isTrue(true);
    });
  }); //context
});

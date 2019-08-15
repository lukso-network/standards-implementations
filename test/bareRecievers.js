const BareMockToken = artifacts.require("BareMockToken");
const KeyManager = artifacts.require("SimpleKeyManager");
const BareDelegateReciever = artifacts.require("BareDelegateReciever");
const RecievingDelegate = artifacts.require("RecievingDelegate");
const RecievingExternal = artifacts.require("RecievingExternal");
const RecievingSelf = artifacts.require("RecievingSelf");

const {
  BN,
  ether,
  expectRevert,
  expectEvent
} = require("openzeppelin-test-helpers");

contract("Bare Recievers Complete Scenarios", accounts => {
  context("Using delegateCall + keyManager", async () => {
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
      account = await BareDelegateReciever.new({ from: owner });
      manager = await KeyManager.new(account.address, { from: owner });
      await account.changePerformDelegate(true, { from: owner });

      // Deploy Recieving
      recieving = await RecievingDelegate.new(wallet);
      await account.changeRecievingDelegate(recieving.address, {
        from: owner
      });
      await account.setData(walletKey, wallet, { from: owner });
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

  context("Using delegateCall + Self Redirecting", async () => {
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
      account = await BareDelegateReciever.new({ from: owner });
      manager = await KeyManager.new(account.address, { from: owner });
      await account.changePerformDelegate(true, { from: owner });

      // Deploy Recieving
      recieving = await RecievingSelf.new(wallet);
      await account.changeRecievingDelegate(recieving.address, {
        from: owner
      });
      await account.setData(walletKey, wallet, { from: owner });
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
      account = await BareDelegateReciever.new({ from: owner });
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

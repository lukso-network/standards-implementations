const UniversalReciever = artifacts.require("BasicUniversalReciever");
const Recieving = artifacts.require("Recieving");
const ExternalReciever = artifacts.require("ExternalReciever");
const DelegateReciever = artifacts.require("DelegateReciever");
//const Caller = artifacts.require("Caller");
const BasicBareReciever = artifacts.require("BasicBareReciever");
const BasicTypedReciever = artifacts.require("BasicTypedReciever");

const {
  BN,
  ether,
  expectRevert,
  expectEvent
} = require("openzeppelin-test-helpers");

contract("Recievers", accounts => {
  context("Call vs DelegateCall", async () => {
    const owner = accounts[2];
    let externalRec,
      delegateRec,
      recieving = {};

    beforeEach(async () => {
      recieving = await Recieving.new();
      externalRec = await ExternalReciever.new({ from: owner });
      delegateRec = await DelegateReciever.new({ from: owner });
      await externalRec.changeRecievingDelegate(recieving.address, {
        from: owner
      });
      await delegateRec.changeRecievingDelegate(recieving.address, {
        from: owner
      });
    });

    // it("Execute in correct context", async () => {
    //   const to = accounts[3];
    //   const from = accounts[4];
    //   const amount = ether("10");
    //   const typeId = web3.utils.asciiToHex("Type");
    //   const data = web3.utils.asciiToHex("data");

    //   let extTx = await externalRec.recieve(typeId, from, to, amount, data);
    //   let delTx = await delegateRec.recieve(typeId, from, to, amount, data);

    //   console.log(extTx);
    // });

    it("Basic gas comparison", async () => {
      const to = accounts[3];
      const from = accounts[4];
      const amount = ether("10");
      const typeId = web3.utils.asciiToHex("Type");
      const data = web3.utils.asciiToHex("data");

      let extTx = await externalRec.recieve(typeId, from, to, amount, data);
      let delTx = await delegateRec.recieve(typeId, from, to, amount, data);

      console.log("External call gas usage: ", extTx.receipt.gasUsed);
      console.log("Delegate call gas usage: ", delTx.receipt.gasUsed);
    });

    it("Fires events from correct addresses", async () => {
      const to = accounts[3];
      const from = accounts[4];
      const amount = ether("10");
      const typeId =
        "0x5479706500000000000000000000000000000000000000000000000000000000";
      const data = web3.utils.asciiToHex("data");

      let extTx = await externalRec.recieve(typeId, from, to, amount, data);
      let delTx = await delegateRec.recieve(typeId, from, to, amount, data);

      await expectEvent.inTransaction(
        extTx.receipt.transactionHash,
        Recieving,
        "RecievedCustom",
        (eventArgs = {
          self: recieving.address,
          msgSender: externalRec.address,
          from: from,
          amount: amount,
          data: data
        })
      );

      await expectEvent.inTransaction(
        delTx.receipt.transactionHash,
        Recieving,
        "RecievedCustom",
        (eventArgs = {
          self: delegateRec.address,
          msgSender: accounts[0],
          from: from,
          amount: amount,
          data: data
        })
      );
    });
  }); // Context

  context("Bare reciever vs Typed Reciever", async () => {
    let bareReciever,
      typedReciever = {};

    const typeId =
      "0x5479706500000000000000000000000000000000000000000000000000000000";
    const to = accounts[3];
    const from = accounts[4];
    const amount = ether("100");
    const data = web3.utils.asciiToHex("data");

    //Manually constructing a bara data parameter
    const bareData = from + to.slice(2) + amount.toString(16, 64);

    beforeEach(async () => {
      bareReciever = await BasicBareReciever.new();
      typedReciever = await BasicTypedReciever.new();
    });

    it("Both recievers emit events correctly", async () => {
      let bareTx = await bareReciever.recieve(typeId, bareData);
      let typedTx = await typedReciever.recieve(typeId, from, to, amount, data);

      await expectEvent.inTransaction(
        bareTx.receipt.transactionHash,
        BasicBareReciever,
        "TokenRecieved",
        (eventArgs = {
          from: from,
          to: to,
          amount: amount
        })
      );

      await expectEvent.inTransaction(
        typedTx.receipt.transactionHash,
        BasicTypedReciever,
        "TokenRecieved",
        (eventArgs = {
          from: from,
          to: to,
          amount: amount
        })
      );
    });

    it("Gas comparisson", async () => {
      let bareTx = await bareReciever.recieve(typeId, bareData);
      let typedTx = await typedReciever.recieve(typeId, from, to, amount, data);
      console.log("Bare reciever gas usage: ", bareTx.receipt.gasUsed);
      console.log("Typed Reciever gas usage: ", typedTx.receipt.gasUsed);
    });
  });
});

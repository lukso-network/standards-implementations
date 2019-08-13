const UniversalReciever = artifacts.require("BasicUniversalReciever");
// const Recieving = artifacts.require("Recieving");
// const AccountReciever = artifacts.require("AccountReciever");
// const AccountRecieverDelegate = artifacts.require("AccountRecieverDelegate");
const Caller = artifacts.require("Caller");
const BasicBareReciever = artifacts.require("BasicBareReciever");
const BasicTypedReciever = artifacts.require("BasicTypedReciever");

const {
  BN,
  ether,
  expectRevert,
  expectEvent
} = require("openzeppelin-test-helpers");

contract("Recievers", accounts => {
  // context("Call vs DelegateCall", async () => {
  //   const owner = accounts[2];
  //   let accReciever,
  //     delReciever,
  //     recieving = {};

  //   beforeEach(async () => {
  //     recieving = await Recieving.new();
  //     accReciever = await AccountReciever.new({ from: owner });
  //     delReciever = await AccountRecieverDelegate.new({ from: owner });
  //     await accReciever.changeRecievingDelegate(recieving.address, {
  //       from: owner
  //     });
  //     await delReciever.changeRecievingDelegate(recieving.address, {
  //       from: owner
  //     });
  //   });

  //   it("Basic gas comparison", async () => {
  //     const to = accounts[3];
  //     const from = accounts[4];
  //     const amount = ether("10");
  //     const typeId = web3.utils.asciiToHex("Type");
  //     const data = web3.utils.asciiToHex("data");

  //     let callTx = await accReciever.recieve(typeId, from, to, amount, data);
  //     let delTx = await delReciever.recieve(typeId, from, to, amount, data);

  //     console.log("Regular call gas usage: ", callTx.receipt.gasUsed);
  //     console.log("DelegateCall gas usage: ", delTx.receipt.gasUsed);
  //   });

  //   it("Fires events from correct addresses", async () => {
  //     const to = accounts[3];
  //     const from = accounts[4];
  //     const amount = ether("10");
  //     const typeId =
  //       "0x5479706500000000000000000000000000000000000000000000000000000000";
  //     const data = web3.utils.asciiToHex("data");

  //     let callTx = await accReciever.recieve(typeId, from, to, amount, data);
  //     let delTx = await delReciever.recieve(typeId, from, to, amount, data);

  //     await expectEvent.inTransaction(
  //       callTx.receipt.transactionHash,
  //       Recieving,
  //       "RecievedCustom",
  //       (eventArgs = {
  //         typeId: typeId,
  //         from: from,
  //         to: recieving.address,
  //         amount: amount,
  //         data: data
  //       })
  //     );

  //     await expectEvent.inTransaction(
  //       delTx.receipt.transactionHash,
  //       Recieving,
  //       "RecievedCustom",
  //       (eventArgs = {
  //         typeId: typeId,
  //         from: from,
  //         to: delReciever.address,
  //         amount: amount,
  //         data: data
  //       })
  //     );
  //   });
  // }); // Context

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

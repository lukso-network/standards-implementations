const UniversalReciever = artifacts.require("BasicUniversalReciever");
const Caller = artifacts.require("Caller");
const { BN, ether, expectRevert } = require("openzeppelin-test-helpers");

contract("UniversalReciever", accounts => {
  context("Recieving and parsing inputs", async () => {
    let reciever,
      caller = {};

    beforeEach(async () => {
      reciever = await UniversalReciever.new();
      caller = await Caller.new();
    });

    it("Can parse inputs correctly", async () => {
      let tx = await caller.callReciever(reciever.address);
      console.log(tx);
    });
  });
});

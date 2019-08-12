const UniversalReciever = artifacts.require("BasicUniversalReciever");
const Caller = artifacts.require("Caller");
const { BN, ether, expectRevert } = require("openzeppelin-test-helpers");

contract("UniversalReciever", accounts => {
  context("Recieving and parsing inputs", async () => {
    let reciever,
      caller = {};

    beforeEach(async () => {
      reciever = await UniversalReciever.new([
        "0x1317f51c845ce3bfb7c268e5337a825f12f3d0af9584c2bbfbf4e64e314eaf73"
      ]);
      caller = await Caller.new();
    });

    it("Can parse inputs correctly", async () => {
      let tx = await caller.callBareTokenReciever(reciever.address);
      //console.log(tx);
      //assert.isTrue(false);
    });
  });
});

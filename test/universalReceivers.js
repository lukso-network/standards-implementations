const UniReceiver = artifacts.require("UniversalReceiverExample");
const UniversalReciverTester = artifacts.require("UniversalReciverTester");
// const ExternalReceiver = artifacts.require("ExternalReceiver");
// const DelegateReceiver = artifacts.require("DelegateReceiver");
// const BasicBareReceiver = artifacts.require("BasicBareReceiver");

const {
    BN,
    ether,
    expectRevert,
    expectEvent
} = require("openzeppelin-test-helpers");

contract("Receivers", accounts => {
    let uni = {};
    const TOKENS_RECIPIENT_INTERFACE_HASH = "0x2352f13a810c120f366f70972476f743e16a9f2196b4b60037b84185ecde66d3";

    beforeEach(async () => {
        uni = await UniReceiver.new();
    });

    it("Can check for implementing interface", async () => {
        let tx = await uni.universalReceiver(TOKENS_RECIPIENT_INTERFACE_HASH, "0x");
        console.log(
            "Directly checking for implementing interface costs: ",
            tx.receipt.gasUsed
        );
        let res = await uni.universalReceiver.call(TOKENS_RECIPIENT_INTERFACE_HASH, "0x");
        assert.equal(res, TOKENS_RECIPIENT_INTERFACE_HASH);
    });

    // it("Can check for implementing interface with Bytes", async () => {
    //     let tx = await uni.universalReceiver(TOKENS_RECIPIENT_INTERFACE_HASH, "0x");
    //     console.log(
    //         "Directly checking for implementing interface using bytes costs: ",
    //         tx.receipt.gasUsed
    //     );
    //     let res = await uni.universalReceiverBytes.call(TOKENS_RECIPIENT_INTERFACE_HASH, "0x");
    //     assert.equal(res, TOKENS_RECIPIENT_INTERFACE_HASH);
    // });

    it("Contract can check for implementing interface with Bytes32", async () => {
        let checker = await UniversalReciverTester.new();
        let tx = await checker.checkImplementation(uni.address, TOKENS_RECIPIENT_INTERFACE_HASH);
        console.log(
            "Contract checking for implementing interface using bytes32 costs: ",
            tx.receipt.gasUsed
        );
        let res = await checker.checkImplementation.call(
            uni.address,
            TOKENS_RECIPIENT_INTERFACE_HASH
        );
        assert.isTrue(res);
    });

    it("Contract can check for implementing interface with Low Level call", async () => {
        let checker = await UniversalReciverTester.new();
        let tx = await checker.lowLevelCheckImplementation(
            uni.address,
            TOKENS_RECIPIENT_INTERFACE_HASH
        );
        console.log(
            "Contract checking for implementing interface using low level and bytes32 costs: ",
            tx.receipt.gasUsed
        );
        let res = await checker.checkImplementation.call(
            uni.address,
            TOKENS_RECIPIENT_INTERFACE_HASH
        );
        assert.isTrue(res);
    });

    // it("Contract can check for implementing interface with Bytes", async () => {
    //     let checker = await UniversalReciverTester.new();
    //     let tx = await checker.checkImplementationBytes(
    //         uni.address,
    //         TOKENS_RECIPIENT_INTERFACE_HASH
    //     );
    //     console.log(
    //         "Contract checking for implementing interface using bytes return costs: ",
    //         tx.receipt.gasUsed
    //     );
    //     let res = await checker.checkImplementation.call(
    //         uni.address,
    //         TOKENS_RECIPIENT_INTERFACE_HASH
    //     );
    //     assert.isTrue(res);
    // });

    // it("Contract can check for implementing interface with Low Level cal + Bytes", async () => {
    //     let checker = await UniversalReciverTester.new();
    //     let tx = await checker.lowLevelCheckImplementationBytes(
    //         uni.address,
    //         TOKENS_RECIPIENT_INTERFACE_HASH
    //     );
    //     console.log(
    //         "Contract checking for implementing interface using low level and bytes return costs: ",
    //         tx.receipt.gasUsed
    //     );
    //     let res = await checker.checkImplementation.call(
    //         uni.address,
    //         TOKENS_RECIPIENT_INTERFACE_HASH
    //     );
    //     assert.isTrue(res);
    // });
});

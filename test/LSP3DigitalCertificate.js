const {expectRevert, singletons} = require("openzeppelin-test-helpers");


const Account = artifacts.require("Account");
const PlainERC725Account = artifacts.require("ERC725Account");
const DigitalCertificateFungible = artifacts.require("LSP3DigitalCertificate");
const ExternalERC777UniversalReceiverTester = artifacts.require("ExternalERC777UniversalReceiverTester");
const ExternalERC777UniversalReceiverRejectTester = artifacts.require("ExternalERC777UniversalReceiverRejectTester");


// Get key: keccak256('LSP1UniversalReceiverDelegate')
const UNIVERSALRECEIVER_KEY = '0x0cfc51aec37c55a4d0b1a65c6255c4bf2fbdf6277f3cc0730c45b828b6db8b47';
// keccak256("ERC777TokensRecipient")
const TOKENS_RECIPIENT_INTERFACE_HASH = "0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b";
const OPERATION_CALL = 0;

// TESTS
// ERC777 transfers
// pausing
// return of all token holders
// minting
// removeDefaultOperators


contract("LSP3DigitalCertificate", accounts => {
    const owner = accounts[9];
    let account,
        tokenHolder = accounts[1],
        defaultOperator = accounts[5],
        digitalCertificate = {};

    beforeEach(async () => {
        // create accounts
        account = await Account.new(owner);

        digitalCertificate = await DigitalCertificateFungible.new(tokenHolder, "MyDigitalCloth", "DIGICLOTH01", [defaultOperator, account.address]);
        // for simplification we have an external account as first owner
        await digitalCertificate.mint(tokenHolder, '100', {from: tokenHolder});


        // change ownership  of the digital certificate to account
        await digitalCertificate.transferOwnership(account.address, {from: tokenHolder});

        assert.equal(await digitalCertificate.owner(), account.address);
        assert.equal(await digitalCertificate.minter(), account.address);

        // set ERC1820 implementer
        // const callData = erc1820.contract.methods.setInterfaceImplementer(account.address, TOKENS_RECIPIENT_INTERFACE_HASH, account.address).encodeABI();
        // await account.execute(OPERATION_CALL, erc1820.address, 0, callData, {from: owner});
    });

    it("Remove default operator", async () => {
        assert.deepEqual(await digitalCertificate.defaultOperators(),  [defaultOperator, account.address]);
        assert.isTrue(await digitalCertificate.isOperatorFor(defaultOperator, tokenHolder));

        await expectRevert(
            digitalCertificate.removeDefaultOperators({from: accounts[0]}),
            "Only default operators can call this function"
        );

        await digitalCertificate.removeDefaultOperators( {from: defaultOperator});

        assert.deepEqual(await digitalCertificate.defaultOperators(),  []);
        assert.isFalse(await digitalCertificate.isOperatorFor(defaultOperator, tokenHolder));
        assert.isFalse(await digitalCertificate.isOperatorFor(account.address, tokenHolder));
    });

    it("Transfer correctly between regular addresses", async () => {
        const receiver = accounts[2];
        let initBal = await digitalCertificate.balanceOf(receiver);

        await digitalCertificate.transfer(receiver, 50, {from: tokenHolder});
        await digitalCertificate.send(receiver, 50, "0x", {from: tokenHolder});

        let finBal = await digitalCertificate.balanceOf(receiver);
        assert.isTrue(finBal.toNumber() > initBal.toNumber());
        assert.equal(finBal.toNumber(), 100);

        // test tokenholders return
        assert.deepEqual(await digitalCertificate.allTokenHolders(),[
            '0x000000000000000000000000'+ tokenHolder.replace('0x','').toLowerCase(),
            '0x000000000000000000000000'+ receiver.replace('0x','').toLowerCase()
        ]);
    });
    it("Send to account implementing universal receiver", async () => {
        let initBal = await digitalCertificate.balanceOf(account.address);
        await digitalCertificate.send(account.address, 50, "0x", {from: tokenHolder});
        let finBal = await digitalCertificate.balanceOf(account.address);

        assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
    it("Rejects account not implementing universal receiver", async () => {
        const receiver = await PlainERC725Account.new(accounts[0]);
        await expectRevert(
            digitalCertificate.send(receiver.address, 50, "0x", {from: tokenHolder}),
            "ERC777: token recipient contract has no universal receiver for 'ERC777TokensRecipient'"
        );
    });
    it("Rejects any transfer when paused", async () => {

        await expectRevert(
            digitalCertificate.pause({from: accounts[0]}),
            "Only default operators can call this function"
        );

        // pause
        await digitalCertificate.pause({from: defaultOperator});

        await expectRevert(
            digitalCertificate.send(accounts[2], 50, "0x", {from: tokenHolder}),
            "Pausable: paused"
        );
        await expectRevert(
            digitalCertificate.transfer(accounts[2], 50, {from: tokenHolder}),
            "Pausable: paused"
        );

        // unpause
        await digitalCertificate.unpause({from: defaultOperator});

        // should be able to send again
        await digitalCertificate.send(accounts[2], 50, "0x", {from: tokenHolder});
    });
    it("Send to account delegating universal receiver to another smart contract", async () => {
        let externalUniversalReceiver = await ExternalERC777UniversalReceiverTester.new();
        await account.setData(UNIVERSALRECEIVER_KEY, externalUniversalReceiver.address, {
            from: owner
        });

        const receiver = account.address;
        let initBal = await digitalCertificate.balanceOf(receiver);
        await digitalCertificate.send(receiver, 50, "0x", {from: tokenHolder});
        let finBal = await digitalCertificate.balanceOf(receiver);

        assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
    it("Send to account where the delegating universal receiver will reject it", async () => {
        let externalUniversalReceiver = await ExternalERC777UniversalReceiverRejectTester.new();
        await account.setData(UNIVERSALRECEIVER_KEY, externalUniversalReceiver.address, {
            from: owner
        });

        await expectRevert(
            digitalCertificate.send(account.address, 50, "0x", {from: tokenHolder}),
            "We reject everything"
        );
    });

    it("Forcefully send regardless of interface (using ERC20 transfer)", async () => {
        const receiver = await PlainERC725Account.new(accounts[0]);
        let initBal = await digitalCertificate.balanceOf(receiver.address);
        await digitalCertificate.transfer(receiver.address, 50, {from: tokenHolder});
        let finBal = await digitalCertificate.balanceOf(receiver.address);
        assert.isTrue(finBal.toNumber() > initBal.toNumber());
    });
});

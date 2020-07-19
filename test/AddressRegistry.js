const {expectRevert} = require("openzeppelin-test-helpers");

const AddressRegistry = artifacts.require('AddressRegistry');


contract("AddressRegistry", async (accounts) => {
    let addressRegistry;

    before(async () => {
        addressRegistry = await AddressRegistry.new();
    });

    it('add address', async function() {

        await addressRegistry.addAddress(accounts[1]);

        assert.equal(await addressRegistry.getAddress(0), accounts[1]);
    });

    it('add same address', async function() {

        assert.isTrue(await addressRegistry.containsAddress(accounts[1]));

        await addressRegistry.addAddress(accounts[1]);

        assert.equal(await addressRegistry.getAddress(0), accounts[1]);
    });

    it('add and remove address', async function() {

        await addressRegistry.addAddress(accounts[4]);

        assert.isTrue(await addressRegistry.containsAddress(accounts[4]));

        await addressRegistry.removeAddress(accounts[4]);

        assert.isFalse(await addressRegistry.containsAddress(accounts[4]));
    });

    it('should give the right count', async function() {
        assert.equal(await addressRegistry.length(), '1');

        // add new entry
        await addressRegistry.addAddress(accounts[2]);

        assert.equal(await addressRegistry.length(), '2');
    });

    it('get correct index', async function() {
        assert.equal(await addressRegistry.getIndex(accounts[1]), '0');
        assert.equal(await addressRegistry.getIndex(accounts[2]), '1');

        expectRevert(
            addressRegistry.getIndex(accounts[4]),
            "EnumerableSet: Index not found"
        );
    });


    it('can list all values of the registry', async function() {
        let length = await addressRegistry.length();
        let values = [];

        for(let i = 0; i < length; i++) {
            values.push(await addressRegistry.getAddress(i));
        }

        assert.deepEqual(values, [
            accounts[1],
            accounts[2]
        ]);
    });

    it('can get all raw values in one call', async function() {
        assert.deepEqual(await addressRegistry.getAllRawValues(), [
            '0x000000000000000000000000' + accounts[1].replace('0x','').toLowerCase(),
            '0x000000000000000000000000' + accounts[2].replace('0x','').toLowerCase()
        ]);
    });

});

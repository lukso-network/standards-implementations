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

    it('should give the right count', async function() {
        assert.equal(await addressRegistry.length(), '1');

        // add new entry
        await addressRegistry.addAddress(accounts[2]);

        assert.equal(await addressRegistry.length(), '2');
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

});

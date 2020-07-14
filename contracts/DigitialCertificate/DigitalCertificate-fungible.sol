// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// modules
import "erc725/contracts/ERC725/ERC725Y.sol";
import "../Tokens/ERC777-UniversalReceiver.sol";

abstract contract DigitalCertificate is ERC725Y, ERC777UniversalReceiver {

    bytes32[] public dataKeys;

    // TODO add freeze function to allow migration, add default operator us?

    constructor(
        address newOwner,
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    )
    ERC725Y(newOwner)
    ERC777UniversalReceiver(name, symbol, defaultOperators)
    public {

    }

    /* non-standard public functions */

    function dataCount() public view returns (uint256) {
        return dataKeys.length;
    }

    /* Public functions */

    function setData(bytes32 _key, bytes memory _value)
    external
    override
    onlyOwner
    {
        if(store[_key].length == 0) {
            dataKeys.push(_key); // 30k more gas on initial set
        }
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }


    /* Modifers */

}

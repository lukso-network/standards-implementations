// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// interfaces
import "../_ERCs/IERC725Y.sol";

// modules
import "./ERC725base.sol";
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

contract ERC725Y is ERC165, IERC725Y, ERC725base {

    bytes4 internal constant _INTERFACE_ID_ERC725Y = 0x00896ac9;

    mapping(bytes32 => bytes) internal store;

    constructor(address _newOwner) public {
        _owner = _newOwner;

        _registerInterface(_INTERFACE_ID_ERC725Y);
    }

    /* Public functions */

    function getData(bytes32 _key)
    public
    view
    override
    virtual
    returns (bytes memory _value)
    {
        return store[_key];
    }

    function setData(bytes32 _key, bytes memory _value)
    external
    override
    virtual
    onlyOwner
    {
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }


    /* Modifiers */

}

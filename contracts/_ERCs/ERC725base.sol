// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// interfaces
import "../_ERCs/IERC725base.sol";

// modules
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

// /ibraries
import "../../node_modules/@openzeppelin/contracts/utils/Create2.sol";
import "../../node_modules/solidity-bytes-utils/contracts/BytesLib.sol";


// This contract should not be used directly, no constructor exists to set the `_owner`
abstract contract ERC725base is IERC725base {

    address internal _owner;

    /* Public functions */

    function owner()
    external
    view
    override
    returns (address) {
        return _owner;
    }

    function changeOwner(address _newOwner)
    public
    override
    virtual
    onlyOwner
    {
        _owner = _newOwner;
        emit OwnerChanged(_owner);
    }


    /* Modifiers */

    modifier onlyOwner() virtual {
        require(msg.sender == _owner, "Only the owner can call this method");
        _;
    }
}

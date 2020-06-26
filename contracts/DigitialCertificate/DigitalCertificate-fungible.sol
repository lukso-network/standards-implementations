// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

import "../_ERCs/IERC725.sol";
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

import "../Tokens/ERC777-UniversalReceiver.sol";

abstract contract DigitalCertificate is ERC165, IERC725, ERC777UniversalReiceiver {

    bytes4 internal constant _INTERFACE_ID_ERC725 = 0xcafecafe; // TODO change

    mapping(bytes32 => bytes) internal store;
    bytes32[] public storeIds;
    address public owner;


    constructor(address _owner) public {
        owner = _owner;

        _registerInterface(_INTERFACE_ID_ERC725);
    }

    /* non-standard public functions */

    function storeCount() public view returns (uint256) {
        return storeIds.length;
    }

    /* Public functions */

    function changeOwner(address _newOwner)
    override
    public
    onlyOwner
    {
        owner = _newOwner;
        emit OwnerChanged(owner);
    }

    function getData(bytes32 _key)
    override
    public
    view
    returns (bytes memory _value)
    {
        return store[_key];
    }

    function setData(bytes32 _key, bytes memory _value)
    override
    external
    onlyOwner
    {
        store[_key] = _value;
        storeIds.push(_key); // 30k more gas on initial set
        emit DataChanged(_key, _value);
    }


    /* Modifers */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this method");
        _;
    }
}

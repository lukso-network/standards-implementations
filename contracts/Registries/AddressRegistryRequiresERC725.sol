// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;


// libraries
import "./AddressRegistry.sol";


contract AddressRegistryRequiresERC725 is AddressRegistry {
    bytes4 _INTERFACE_ID_ERC725Y = 0x2bd57b73;

    function addAddress(address _address)
    public
    override
    returns(bool)
    {
        require(ERC165(msg.sender).supportsInterface(_INTERFACE_ID_ERC725Y), 'Only ERC725Y can call this function');
        return addressSet.add(_address);
    }

    function removeAddress(address _address)
    public
    override
    returns(bool)
    {
        require(ERC165(msg.sender).supportsInterface(_INTERFACE_ID_ERC725Y), 'Only ERC725Y can call this function');
        return addressSet.remove(_address);
    }
}

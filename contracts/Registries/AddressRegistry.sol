// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;


// libraries
import "@openzeppelin/contracts/utils/EnumerableSet.sol";


contract AddressRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private addressSet;


    function addAddress(address _address)
    public
    returns(bool)
    {
        return addressSet.add(_address);
    }

    function removeAddress(address _address)
    public
    returns(bool)
    {
        return addressSet.remove(_address);
    }


    function getAddress(uint256 _index)
    public
    view
    returns (address)
    {
        return addressSet.at(_index);
    }

    function getIndex(address _address)
    public
    view
    returns (uint256)
    {
        require(addressSet.contains(_address), 'EnumerableSet: Index not found');
        return addressSet._inner._indexes[bytes32(uint256(_address))] - 1;
    }

    function getAllRawValues()
    public
    view
    returns (bytes32[] memory)
    {
        return addressSet._inner._values;
    }


    function containsAddress(address _address)
    public
    view
    returns (bool)
    {
        return addressSet.contains(_address);
    }


    function length()
    public
    view
    returns (uint256)
    {
        return addressSet.length();
    }

}

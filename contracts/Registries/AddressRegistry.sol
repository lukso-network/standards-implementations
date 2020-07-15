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


    function getAddress(uint256 _index)
    public
    view
    returns (address)
    {
        return addressSet.at(_index);
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

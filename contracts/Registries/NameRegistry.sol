// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;


// libraries
import "../Libraries/EnumerableMapBytes32Bytes.sol";
import "../Libraries/EnumerableMapBytes32.sol";

contract NameRegistry {
     using EnumerableMapBytes for EnumerableMapBytes.Bytes32ToBytesMap;
     using EnumerableMapBytes32 for EnumerableMapBytes32.Bytes32ToBytes32Map;

    EnumerableMapBytes.Bytes32ToBytesMap private nameReg;
    EnumerableMapBytes32.Bytes32ToBytes32Map private addressReg;


    function setName(bytes memory _name)
    public
    returns(bool)
    {
        bytes32 sender = bytes32(uint256(msg.sender));
        bytes32 nameHash = keccak256(_name);

        require(!addressReg.contains(nameHash) || addressReg.get(nameHash) == sender, "Only the initial setter can edit this name");

        // remove old key if present
        if (nameReg.contains(sender)) {
            bytes memory oldName = nameReg.get(sender);
            addressReg.remove(keccak256(oldName));
        }

        addressReg.set(nameHash, sender);
        nameReg.set(sender, _name);


        return true;
    }


    function getName(address _address)
    public
    view
    returns (bytes memory)
    {
        return nameReg.get(bytes32(uint256(_address)));
    }


    function getAddress(bytes memory _name)
    public
    view
    returns (address)
    {
        bytes32 nameHash = keccak256(_name);
        return address(uint256(addressReg.get(nameHash)));
    }

    function containsName(bytes memory _name)
    public
    view
    returns (bool)
    {
        bytes32 nameHash = keccak256(_name);
        return addressReg.contains(nameHash);
    }

    function containsAddress(address _address)
    public
    view
    returns (bool)
    {
        return nameReg.contains(bytes32(uint256(_address)));
    }


    function length()
    public
    view
    returns (uint256)
    {
        return nameReg.length();
    }


    function atIndex(uint256 _index)
    public
    view
    returns (address setter, bytes memory name)
    {
        (bytes32 key, bytes memory value) = nameReg.at(_index);
        return (address(uint256(key)), value);
    }

}

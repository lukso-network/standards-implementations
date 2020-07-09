// SPDX-License-Identifier: Apache-2.0
/*
 * @title ERC725Account implementation for LUKSO
 * @author Fabian Vogelsteller <fabian@lukso.network>
 *
 * @dev Implementation of the ERC725Account + LSP1 universalReceiver
 */
pragma solidity ^0.6.0;

// interfaces
import "../_LSPs/ILSP1_UniversalReceiver.sol";
import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";

// modules
import "erc725/contracts/ERC725/ERC725Account.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";

interface ILSP1Delegate {
    function universalReceiver(address sender, bytes32 typeId, bytes memory data) external returns (bytes32);
}

contract Account1820 is ERC165, ERC725Account, ILSP1 {

    bytes4 _INTERFACE_ID_LSP1 = 0x6bb56a14;
    IERC1820Registry private ERC1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
    0x2352f13a810c120f366f70972476f743e16a9f2196b4b60037b84185ecde66d3; // keccak256("LSP1_ERC777TokensRecipient")

    bytes32 constant private _UNIVERSALRECEIVER_KEY =
    0x8619f233d8fc26a7c358f9fc6d265add217d07469cf233a61fc2da9f9c4a3205; // keccak256("LSP1UniversalReceiverAddress")

    bytes32[] public storeKeys;



    constructor(address _newOwner) ERC725Account(_newOwner) public {

        // Add the key of the ERC725Type set in the constructor of ERC725Account
        storeKeys.push(keccak256('ERC725Type'));

        _registerInterface(_INTERFACE_ID_LSP1);

        // ERC 1820
        ERC1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    /* non-standard public functions */

    function storeCount() public view returns (uint256) {
        return storeKeys.length;
    }

    /* Public functions */

    function setData(bytes32 _key, bytes memory _value)
    external
    override
    onlyOwner
    {
        if(store[_key].length == 0) {
            storeKeys.push(_key); // 30k more gas on initial set
        }
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }

    /**
    * @notice Notify the smart contract about any received asset
    * LSP1 interface

    * @param _typeId The type of transfer received
    * @param _data The data received
    */
    function universalReceiver(bytes32 _typeId, bytes memory _data)
    external
    override
    virtual
    returns (bytes32 returnValue)
    {
        bytes memory receiverData = getData(_UNIVERSALRECEIVER_KEY);
        returnValue = "";

        // call external contract
        if (receiverData.length == 20) {
            address universalReceiverAddress = BytesLib.toAddress(receiverData, 0);

            returnValue = ILSP1Delegate(universalReceiverAddress).universalReceiver(_msgSender(), _typeId, _data);
        }

        emit UniversalReceiver(_msgSender(), _typeId, returnValue, _data);

        return returnValue;
    }
}

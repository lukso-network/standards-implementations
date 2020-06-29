// SPDX-License-Identifier: Apache-2.0
/*
 * @title ERC725 implementation
 * @author Fabian Vogelsteller <fabian@lukso.network>
 *
 * @dev Implementation of the ERC725 standard + LSP1 universalReceiver + ERC1271 signatureValidation
 */
pragma solidity ^0.6.0;

// interfaces
import "../_ERCs/IERC1271.sol";
import "../_LSPs/ILSP1_UniversalReceiver.sol";
import "../../node_modules/@openzeppelin/contracts/introspection/IERC1820Registry.sol";

// modules
import "../_ERCs/ERC725.sol";
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

// libraries
import "../../node_modules/@openzeppelin/contracts/cryptography/ECDSA.sol";
import "../utils/UtilsLib.sol";

contract Account is ERC165, ERC725, IERC1271, ILSP1 {

    IERC1820Registry private ERC1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    // TODO change to universalReceiver?
    // keccak256("ERC777TokensRecipient")
    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
    0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    bytes4 internal constant _INTERFACE_ID_ERC1271 = 0x1626ba7e;
    bytes4 internal constant _ERC1271FAILVALUE = 0xffffffff;

    bytes32[] public storeKeys;

    constructor(address _newOwner) ERC725(_newOwner) public {

        // ERC 1820
        ERC1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));

        _registerInterface(_INTERFACE_ID_ERC1271);
    }

    /* non-standard public functions */

    function storeCount() public view returns (uint256) {
        return storeKeys.length;
    }

    /* Public functions */

    receive() external payable {}

    function setData(bytes32 _key, bytes memory _value)
    override
    external
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
    * LSP1 interface.

    * @param _typeId The type of transfer received
    * @param _data The data received
    */
    function universalReceiver(bytes32 _typeId, bytes memory _data)
    override
    virtual
    external
    returns (bytes32 returnValue)
    {
        // TODO CHNAGE to sha3(universalReceiver(bytes32,bytes)) ??
        bytes memory receiverData = getData(0x0000000000000000000000000000000000000000000000000000000000000002);

        // TODO add response as third parameter?
        emit Received(_typeId, _data);

        // call external contract
        if (receiverData.length == 20) {
            address universalReceiverAddress = BytesLib.toAddress(receiverData, 0);

            return ILSP1(universalReceiverAddress).universalReceiver(_typeId, _data);
        }

        // if no action was taken
        return 0x0;
    }


    /**
    * @notice Checks if an owner signed `_data`.
    * ERC1271 interface.
    *
    * @param _hash hash of the data signed//Arbitrary length data signed on the behalf of address(this)
    * @param _signature owner's signature(s) of the data
    */
    function isValidSignature(bytes32 _hash, bytes memory _signature)
    override
    public
    view
    returns (bytes4 magicValue)
    {
        if (UtilsLib.isContract(owner())){
            return IERC1271(owner()).isValidSignature(_hash, _signature);
        } else {
//            bytes32 signedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", _data.length, _data));
            //abi.encodePacked(byte(0x19), byte(0x0), address(this), _data));
            return owner() == ECDSA.recover(_hash, _signature)
                ? _INTERFACE_ID_ERC1271
                : _ERC1271FAILVALUE;
        }
    }
}

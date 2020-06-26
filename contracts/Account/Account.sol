// SPDX-License-Identifier: Apache-2.0
/*
 * @title ERC725 implementation
 * @author Fabian Vogelsteller <fabian@lukso.network>
 *
 * @dev Implementation of the ERC725 standard + LSP1 universalReceiver + ERC1271 signatureValidation
 */

pragma solidity ^0.6.0;

import "../_ERCs/IERC725.sol";
import "../_ERCs/IERC1271.sol";
import "../_LSPs/ILSP1_UniversalReceiver.sol";
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

import "../../node_modules/@openzeppelin/contracts/cryptography/ECDSA.sol";
import "../../node_modules/solidity-bytes-utils/contracts/BytesLib.sol";
import "../utils/UtilsLib.sol";

contract Account is ERC165, IERC725, IERC1271, IUniversalReceiver {

    bytes4 internal constant _ERC1271MAGICVALUE = 0x1626ba7e;
    bytes4 internal constant _ERC1271FAILVALUE = 0xffffffff;
    bytes4 internal constant _INTERFACE_ID_ERC725 = 0xcafecafe;

    uint256 constant OPERATION_CALL = 0;
    uint256 constant OPERATION_DELEGATECALL = 1;
    uint256 constant OPERATION_CREATE2 = 2;
    uint256 constant OPERATION_CREATE = 3;

    mapping(bytes32 => bytes) internal store;
    bytes32[] public storeIds;
    address public owner;

    constructor(address _owner) public {
        owner = _owner;

        _registerInterface(_INTERFACE_ID_ERC725);
    }

    /* non-standard public functions */

    function storeCount() public returns (uint256) {
        return storeIds.length;
    }

    /* Public functions */

    receive() external payable {}

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
        storeIds.push(_key);
        emit DataChanged(_key, _value);
    }

    function execute(uint256 _operation, address _to, uint256 _value, bytes memory _data)
    override
    external
    onlyOwner
    {
        uint256 txGas = gasleft() - 2500;

        // CALL
        if (_operation == OPERATION_CALL) {
            executeCall(_to, _value, _data, txGas);

        // DELEGATE CALL
        // TODO: risky as storage slots can be overridden, remove?
        } else if (_operation == OPERATION_DELEGATECALL) {
            address currentOwner = owner;
            executeDelegateCall(_to, _data, txGas);
            // Check that the owner was not overidden
            require(owner == currentOwner, 'Delegate call is not allowed to modify the owner!');

        // CREATE
        } else if (_operation == OPERATION_CREATE) {
            performCreate(_value, _data);

        // CREATE2
        } else if (_operation == OPERATION_CREATE2) {
            bytes32 salt = BytesLib.toBytes32(_data, _data.length - 32);
            bytes memory data = BytesLib.slice(_data, 0, _data.length - 32);
            performCreate2(_value, data, salt);

        } else {
            revert("Wrong operation type");
        }
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

            return IUniversalReceiver(universalReceiverAddress).universalReceiver(_typeId, _data);
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
        if (UtilsLib.isContract(owner)){
            return IERC1271(owner).isValidSignature(_hash, _signature);
        } else {
//            bytes32 signedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", _data.length, _data));
            //abi.encodePacked(byte(0x19), byte(0x0), address(this), _data));
            return owner == ECDSA.recover(_hash, _signature)
                ? _ERC1271MAGICVALUE
                : _ERC1271FAILVALUE;
        }
    }

    /* Internal functions */

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/base/Executor.sol
    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas)
    internal
    returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/base/Executor.sol
    function executeDelegateCall(address to, bytes memory data, uint256 txGas)
    internal
    returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/libraries/CreateCall.sol
    function performCreate(uint256 value, bytes memory deploymentData) public returns(address newContract) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            newContract := create(value, add(deploymentData, 0x20), mload(deploymentData))
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreated(newContract);
    }

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/libraries/CreateCall.sol
    function performCreate2(uint256 value, bytes memory deploymentData, bytes32 salt) public returns(address newContract) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            newContract := create2(value, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreated(newContract);
    }


    /* Modifiers */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this method");
        _;
    }
}

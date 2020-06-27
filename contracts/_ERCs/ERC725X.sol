// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// interfaces
import "../_ERCs/IERC725X.sol";

// modules
import "./ERC725base.sol";
import "../../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

// libraries
import "../../node_modules/@openzeppelin/contracts/utils/Create2.sol";
import "../../node_modules/solidity-bytes-utils/contracts/BytesLib.sol";

contract ERC725X is ERC165, IERC725X, ERC725base  {

    bytes4 internal constant _INTERFACE_ID_ERC725X = 0x6f9c3944;

    uint256 constant OPERATION_CALL = 0;
    uint256 constant OPERATION_DELEGATECALL = 1;
    uint256 constant OPERATION_CREATE2 = 2;
    uint256 constant OPERATION_CREATE = 3;


    constructor(address _newOwner) public {
        _owner = _newOwner;

        _registerInterface(_INTERFACE_ID_ERC725X);
    }

    /* Public functions */

    function execute(uint256 _operation, address _to, uint256 _value, bytes memory _data)
    external
    override
    onlyOwner
    {
        uint256 txGas = gasleft() - 2500;

        // CALL
        if (_operation == OPERATION_CALL) {
            executeCall(_to, _value, _data, txGas);

        // DELEGATE CALL
        // TODO: risky as storage slots can be overridden, remove?
        } else if (_operation == OPERATION_DELEGATECALL) {
            address currentOwner = _owner;
            executeDelegateCall(_to, _data, txGas);
            // Check that the owner was not overidden
            require(_owner == currentOwner, 'Delegate call is not allowed to modify the owner!');

        // CREATE
        } else if (_operation == OPERATION_CREATE) {
            performCreate(_value, _data);

        // CREATE2
        } else if (_operation == OPERATION_CREATE2) {
            bytes32 salt = BytesLib.toBytes32(_data, _data.length - 32);
            bytes memory data = BytesLib.slice(_data, 0, _data.length - 32);

            address contractAddress = Create2.deploy(_value, salt, data);

            emit ContractCreated(contractAddress);

        } else {
            revert("Wrong operation type");
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

    /* Modifiers */

}

pragma solidity ^0.6.0;

import "../_ERCs/IERC725.sol";
import "../_LSPs/ILSP1_UniversalReceiver.sol";

contract Account is IERC725, IUniversalReceiver {

    uint256 constant OPERATION_CALL = 0;
    uint256 constant OPERATION_DELEGATECALL = 1;
    uint256 constant OPERATION_CREATE2 = 2;
    uint256 constant OPERATION_CREATE = 3;

    mapping(bytes32 => bytes) store;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    /* Public functions */

    receive() external {}

    function changeOwner(address _newOwner)
    public
    onlyOwner
    {
        owner = _newOwner;
        emit OwnerChanged(owner);
    }

    function getData(bytes32 _key)
    public
    view
    returns (bytes memory _value)
    {
        return store[_key];
    }

    function setData(bytes32 _key, bytes memory _value)
    external
    onlyOwner
    {
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }

    function execute(uint256 _operation, address _to, uint256 _value, bytes memory _data)
    external
    onlyOwner
    {
        uint256 txGas = gasleft() - 2500;

        if (_operation == OPERATION_CALL) {
            executeCall(_to, _value, _data, txGas);
        } else if (_operation == OPERATION_DELEGATECALL) {
            executeDelegateCall(_to, _value, _data, txGas);
        } else if (_operation == OPERATION_CREATE) {
            performCreate(_value, _data);
        } else if (_operation == OPERATION_CREATE2) {
            bytes32 salt = slice(_data.length - 32, _data.length);
            bytes memory data = slice(0, _data.length - 32);
            performCreate2(_value, data, salt);
        } else {
            revert("Wrong operation type");
        }
    }

    function universalReceiver(bytes32 typeId, bytes memory data)
    external
    returns (bytes32 returnValue)
    {
        address universalReceiverAddress = toAddress(getData(0x0000000000000000000000000000000000000000000000000000000000000002), 12);
        uint256 gasl = gasleft() - 2500;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            returnValue := delegatecall(gasl, universalReceiverAddress, add(data, 0x20), mload(data), 0, 0)
        }
//        emit Received(typeId, data);
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

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
    internal
    pure
    returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length), "Read out of bounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
                tempBytes := mload(0x40)

            // The first word of the slice result is potentially a partial
            // word read from the original array. To read it, we calculate
            // the length of that partial word and start copying that many
            // bytes into the array. The first word we copy will start with
            // data we don't care about, but the last `lengthmod` bytes will
            // land at the beginning of the contents of the new array. When
            // we're done copying, we overwrite the full first word with
            // the actual length of the slice.
                let lengthmod := and(_length, 31)

            // The multiplication in the next line is necessary
            // because when slicing multiples of 32 bytes (lengthmod == 0)
            // the following copy loop was copying the origin's length
            // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                // The multiplication in the next line has the same exact purpose
                // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

            //update free-memory pointer
            //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= (_start + 20), "Read out of bounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    /* Modifiers */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this method");
        _;
    }
}

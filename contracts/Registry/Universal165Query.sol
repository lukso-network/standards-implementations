pragma solidity 0.5.10;

contract Universal165Query {
    bytes32 constant InvalidID = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    bytes32 constant ERC165ID = 0x385bbff703a06899061ed4429435f7c048ad373e3eb2af89c65aba709af58dd4;

    function doesContractImplementInterface(address _contract, bytes32 _typeId) external returns (bool) {
        bool success;

        (success, ) = _contract.call(abi.encodeWithSignature("universalReciever(bytes32, bytes)", ERC165ID, ""));
        if(!success) { return false; }

        (success, ) = _contract.call(abi.encodeWithSignature("universalReciever(bytes32, bytes)", InvalidID, ""));
        if(success) { return false; }

        (success, ) = _contract.call(abi.encodeWithSignature("universalReciever(bytes32, bytes)", _typeId, ""));
        return success;
    }
}
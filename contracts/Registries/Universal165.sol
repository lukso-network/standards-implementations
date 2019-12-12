pragma solidity 0.5.10;

import "../_LSPs/LSP1_UniversalReceiver.sol";


contract Universal165 is UniversalReceiver {

    mapping(bytes32 => bool) public supportedHashes;

    constructor() public {
        //Supports ERC165
        supportedHashes[0x385bbff703a06899061ed4429435f7c048ad373e3eb2af89c65aba709af58dd4] = true;
    }

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32) {
        require(supportedHashes[typeId], "Type not suported");
    }
}
pragma solidity 0.5.10;

import "../UniversalReciever/UniversalReciever.sol";


contract Universal165 is UniversalReciever {

    mapping(bytes32  => bool) public suportedHashes;

    constructor() public {
        //Suports ERC165
        suportedHashes[0x385bbff703a06899061ed4429435f7c048ad373e3eb2af89c65aba709af58dd4] = true;
    }

    function universalReciever(bytes32 typeId, bytes calldata data) external {
        require(suportedHashes[typeId], "Type not suported");
    }
}
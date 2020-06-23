pragma solidity ^0.6.0;

import "./ERC165.sol";

contract ERC165MappingImplementation is ERC165 {
    /// @dev You must not set element 0xffffffff to true
    mapping(bytes4 => bool) internal supportedInterfaces;

    constructor() public {
        supportedInterfaces[ERC165.supportsInterface.selector] = true;
    }

    function supportsInterface(bytes4 interfaceID) override external view returns (bool) {
        return supportedInterfaces[interfaceID];
    }
}

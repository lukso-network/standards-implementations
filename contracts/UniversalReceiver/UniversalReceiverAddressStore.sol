// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// interfaces
import "../_LSPs/ILSP1_UniversalReceiverDelegate.sol";

// modules
import "../Registries/AddressRegistry.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";

contract UniversalReceiverAddressStore is ERC165, ILSP1Delegate, AddressRegistry {

    bytes4 _INTERFACE_ID_LSP1DELEGATE = 0xc2d7bcc1;

    bytes32 constant internal _TOKENS_RECIPIENT_INTERFACE_HASH =
    0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b; // keccak256("ERC777TokensRecipient")

    constructor() public {
        _registerInterface(_INTERFACE_ID_LSP1DELEGATE);
    }

    function universalReceiverDelegate(address sender, bytes32 typeId, bytes memory data) external override returns (bytes32) {
        require(typeId == _TOKENS_RECIPIENT_INTERFACE_HASH, 'UniversalReceiverDelegate: Type not supported');

        addAddress(sender);

        return typeId;
    }
}

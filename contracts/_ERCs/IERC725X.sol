// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.7.0;

import "../_ERCs/IERC725base.sol";

interface IERC725X is IERC725base {
//    event OwnerChanged(address indexed ownerAddress);
    event ContractCreated(address indexed contractAddress);

//    function owner() external view returns (address);
//    function changeOwner(address newOwner) external;
    function execute(uint256 operationType, address to, uint256 value, bytes memory data) external;
}

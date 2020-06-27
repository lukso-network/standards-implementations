// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.7.0;

import "../_ERCs/IERC725base.sol";

interface IERC725Y is IERC725base {
//    event OwnerChanged(address indexed ownerAddress);
    event DataChanged(bytes32 indexed key, bytes value);

//    function owner() external view returns (address);
//    function changeOwner(address newOwner) external;
    function getData(bytes32 key) external view returns (bytes memory value);
    function setData(bytes32 key, bytes memory value) external;
}

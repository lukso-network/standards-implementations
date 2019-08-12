pragma solidity 0.5.10;

import "./Account.sol";

contract SimpleKeyManager {

    address public owner;
    Account public account;

    event Execution(uint256 _operationType, address _to, uint256 _value, bytes _data);
    constructor(address payable _account) public {
        owner = msg.sender;
        account = Account(_account);
    }

     modifier onlyOwner() {
        require(msg.sender == owner, "only-owner-allowed");
        _;
    }

    function execute(uint256 _operationType, address _to, uint256 _value, bytes calldata _data) onlyOwner external {
        account.execute(_operationType, _to, _value, _data);
        emit Execution(_operationType, _to, _value, _data);
    }

}
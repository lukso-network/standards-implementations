pragma solidity 0.5.10;

import "./ERC777Reciever.sol";
import "../../UniversalReciever/UniversalReciever.sol";
import "../../../node_modules/@openzeppelin/contracts/introspection/ERC1820Implementer.sol";
import "../../Account/Account.sol";

contract RecievingAccount is Account, UniversalReciever, ERC1820Implementer {
    
    ERC777Reciever public reciever;

    function changeReciever(address _newReciever) onlyOwner external {
        reciever = ERC777Reciever(_newReciever);
    }

    function universalReciever(bytes32 typeId ,bytes calldata data) external returns(bytes32 ret){
        ret = reciever.universalReciever(msg.sender, typeId,data);
        emit Received(typeId,data);
    }


}

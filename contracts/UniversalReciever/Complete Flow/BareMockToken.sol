pragma solidity 0.5.10;

import "../../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../BareReciever/BasicUniversalReciever.sol";
import "../BareReciever/BareReciever.sol";

/// @title BareMockToken
/// @author @JGCarv
/// @notice Overriden ERC20 to call recipient after transfer
/// @dev This should be replaced for a ERC777-like token in the future
contract BareMockToken is ERC20 {

    constructor() public { 
        _mint(msg.sender, 100 ether);
    }

     function transfer(address recipient, uint256 amount) public returns (bool) {
        super.transfer(recipient, amount);
        if(isContract(recipient)){
            BareReciever br = BareReciever(recipient);
            bytes memory dt = abi.encodePacked( msg.sender,recipient, amount);
            br.recieve(address(this), bytes32(0) , dt);
        }
        return true;
    }

    function isContract(address _addr) internal returns (bool){
        uint256 size;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
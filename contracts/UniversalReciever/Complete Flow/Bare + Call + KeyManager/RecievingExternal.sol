pragma solidity 0.5.10;

import "../../BareReciever/BareReciever.sol";
import "../../../Account/SimpleKeyManager.sol";
import "../../../Account/Account.sol";


contract RecievingExternal {


    event RecievedTokenTransfer(address token, address from,address to, uint256 amount, bytes data);
    event SentTokenToWallet(address token, address wallet, uint amount);

    address tokenWallet;
    address keyManager;

    constructor(address _keyManager, address _tkWallet) public {
        keyManager = _keyManager;
        tokenWallet = _tkWallet;
    }
  
    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function redirectToAddress(address token, address recipient, uint256 amount) internal {
        bytes memory data = abi.encodeWithSelector(0xa9059cbb, recipient, amount);
        // //Bad Naming here
        SimpleKeyManager km = SimpleKeyManager(keyManager);
        km.execute(0,token,0, data);
        emit SentTokenToWallet(token,recipient,amount);
    }
    
    function recieve(address sender, bytes32 typeId, bytes calldata data) external {
        (address from, address to, uint256 amount) = toTokenData(data);
        redirectToAddress(sender, from ,amount);
        emit RecievedTokenTransfer(sender,from,to,amount,data);
    }
}
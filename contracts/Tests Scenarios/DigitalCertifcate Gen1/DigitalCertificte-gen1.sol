pragma solidity 0.5.10;

import "https://github.com/lukso-network/standards-scenarios/blob/digital-certificates/contracts/DigitialCertificate/DigitalCertificate-fungible.sol";

contract DCGen1 is DigitalCertificate {

    constructor(string memory name, string memory symbol, address[] memory defaultOperators) ERC777(name, symbol, defaultOperators) public {
        owner = msg.sender;
    }

    // certificate should not be able to receive ETH/LYX
    function() external {}


    // TODO add execute?


    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     *
     * See `IERC777Sender` and `IERC777Recipient`.
     *
     * Emits `Minted` and `Transfer` events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the `tokensReceived`
     * interface.
     */
    function mint(
        address account,
        uint256 amount
    )
    public
    onlyOwner
    {
        require(account != address(0), "ERC777: mint to the zero address");

        // Update state variables
        ERC777._totalSupply = ERC777._totalSupply.add(amount);
        ERC777._balances[account] = ERC777._balances[account].add(amount);

        ERC777._callTokensReceived(address(0), address(0), account, amount, "", "", false); // Allow transfer to any address

        emit Minted(account, account, amount, "", "");
        emit Transfer(address(0), account, amount);
    }

}
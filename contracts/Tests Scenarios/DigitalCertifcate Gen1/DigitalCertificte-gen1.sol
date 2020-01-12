import "https://github.com/lukso-network/standards-scenarios/blob/digital-certificates/contracts/DigitialCertificate/DigitalCertificate-fungible.sol";

contract DCGen1 is DigitalCertificate {

    constructor(string memory name, string memory symbol, address[] memory defaultOperators) ERC777(name, symbol, defaultOperators) public {

    }

    // certificate should not be able to receive ETH/LYX
    function() external {}


    // TODO add execute?

    /**
     * @dev See `IERC20.transfer`.
     *
     * Overwritten transfer, allows `owner` of the DigitalCertificate, to transfer on behalf of
     *
     * Unlike `send`, `recipient` is _not_ required to implement the `tokensReceived`
     * interface if it is a contract.
     *
     * Also emits a `Sent` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = msg.sender;

        super._callTokensToSend(from, from, recipient, amount, "", "");

        super._move(from, from, recipient, amount, "", "");

        super._callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

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
        super._totalSupply = super._totalSupply.add(amount);
        super._balances[account] = super._balances[account].add(amount);

        super._callTokensReceived(address(0), address(0), account, amount, "", "", false); // Allow transfer to any address

        emit Minted(account, account, amount, "", "");
        emit Transfer(address(0), account, amount);
    }

}
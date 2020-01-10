contract Asset{

	mapping(address => uint) balances;
    uint public totalSupply;

    function balanceOf(address _owner) constant returns (uint) {
        return balances[_owner];
    }

	function transferFrom(address from_account, address to_account, uint amount) public returns (bool) {

		balances[from_account] = balances[from_account] - amount;
		balances[to_account] = balances[to_account] + amount;
		return true;
	}
}
pragma solidity ^0.4.24;


contract TableFactory {
    function openTable(string) public constant returns (Table);  // 打开表
    function createTable(string,string,string) public returns(int);  // 创建表
}

// 查询条件
contract Condition {
    //等于
    function EQ(string, int) public;
    function EQ(string, string) public;
    
    //不等于
    function NE(string, int) public;
    function NE(string, string)  public;
    
    //大于
    function GT(string, int) public;
    //大于或等于
    function GE(string, int) public;
    
    //小于
    function LT(string, int) public;
    //小于或等于
    function LE(string, int) public;
    
    //限制返回记录条数
    function limit(int) public;
    function limit(int, int) public;
}

// 单条数据记录
contract Entry {
    function getInt(string) public constant returns(int);
    function getAddress(string) public constant returns(address);
    function getBytes64(string) public constant returns(byte[64]);
    function getBytes32(string) public constant returns(bytes32);
    function getString(string) public constant returns(string);
    
    function set(string, int) public;
    function set(string, string) public;
    function set(string, address) public;
}

// 数据记录集
contract Entries {
    function get(int) public constant returns(Entry);
    function size() public constant returns(int);
}

// Table主类
contract Table {
    // 查询接口
    function select(string, Condition) public constant returns(Entries);
    // 插入接口
    function insert(string, Entry) public returns(int);
    // 更新接口
    function update(string, Entry, Condition) public returns(int);
    // 删除接口
    function remove(string, Condition) public returns(int);
    
    function newEntry() public constant returns(Entry);
    function newCondition() public constant returns(Condition);
}

contract Asset {


    constructor() public {
        // create a t_asset table in the constructor
        createTable();
    }

    function createTable() private {
        TableFactory tf = TableFactory(0x1001);
        // asset management table, key : account, field : asset_value
        // |  account(primary key)   |  amount       |
        // |-------------------- |-------------------|
        // |        account      |    asset_value    |     
        // |---------------------|-------------------|
        //
        // create table
        tf.createTable("t_asset", "account", "asset_value");
    }

    function openTable() private returns(Table) {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_asset");
        return table;
    }

    /*
    description: query asset amount according to asset account

    parameter:
            account: asset account

    return value：
            parameter1： successfully returns 0, the account does not exist and returns -1
            parameter2： valid when the first parameter is 0, the amount of assets
    */
    function balanceOf(string account) public constant returns(int256, uint256) {
        // open table
        Table table = openTable();
        // query
        Entries entries = table.select(account, table.newCondition());
        uint256 asset_value = 0;
        if (0 == uint256(entries.size())) {
            return (-1, asset_value);
        } else {
            Entry entry = entries.get(0);
            return (0, uint256(entry.getInt("asset_value")));
        }
    }

    function transfer(string from_account, string to_account, uint256 amount) public returns(int256) {
        // query transferred asset account information
        int ret_code = 0;
        int256 ret = 0;
        uint256 from_asset_value = 0;
        uint256 to_asset_value = 0;

        // whather transferred asset account exists?
        (ret, from_asset_value) = balanceOf(from_account);
        // whather received asset account exists?
        (ret, to_asset_value) = balanceOf(to_account);

        Table table = openTable();

        Entry entry0 = table.newEntry();
        entry0.set("account", from_account);
        entry0.set("asset_value", int256(from_asset_value - amount));
        // update transferred account
        table.update(from_account, entry0, table.newCondition());
        Entry entry1 = table.newEntry();
        entry1.set("account", to_account);
        entry1.set("asset_value", int256(to_asset_value + amount));
        // update received account
        table.update(to_account, entry1, table.newCondition());

    }
}
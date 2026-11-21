// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HallymToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    address public owner;

    mapping(address => uint) public balanceOf;
    mapping(address => bool) public blackList;
    mapping(address => uint) public cashbackRate;

    modifier onlyOwner() {
        require(msg.sender == owner, unicode"권한없음");
        _;
    }

    event Transfer(address from, address to, uint amount);
    event BlackListed(address target);
    event DeleteFromBlackList(address target);    
    event SetCashback(address addr, uint rate);
    event Cashback(address from, address to, uint amount);

    constructor(uint supply, string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = supply * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address to, uint amount) external {
        require(balanceOf[msg.sender] >= amount, unicode"잔액부족");
        require(balanceOf[to] + amount >= balanceOf[to], unicode"부정송금");
        require(blackList[msg.sender] != true, unicode"보내는 주소 블랙리스트");
        require(blackList[to] != true, unicode"받는 주소 블랙리스트");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    function blackListing(address addr) external onlyOwner {
        blackList[addr] = true;
        emit BlackListed(addr);
    }

    function deleteFromBlackList(address addr) external onlyOwner {
        blackList[addr] = false;
        emit DeleteFromBlackList(addr);
    }

    function setCashbackRate(uint rate) external {
        if(rate > 100) rate = 100;
        cashbackRate[msg.sender] = rate;
        emit SetCashback(msg.sender, rate);
    }
}

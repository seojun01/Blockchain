// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Owned Contract
contract Owned {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, unicode"권한없음");
        _;
    }

    constructor() {
        owner = msg.sender;
    }    
}

// Member Contract
contract Members is Owned {
    struct GradeStatus {
        string grade; // 등급
        uint times; // 해당 등급을 위한 최저 거래 횟수
        uint sum; // 해당 등급을 위한 최저 거래 금액
        uint rate; // 캐시백 비율(%단위)
    }

    struct MemberHistory {
        uint times; // 거래 횟수
        uint sum; // 거래 금액
        uint statusIndex; // 등급 인덱스
    }

    address public HallymToken;
    GradeStatus[] public status;
    mapping(address => MemberHistory) public tradingHistory;
    
    modifier onlyToken() {
        require(msg.sender == HallymToken, unicode"토큰 컨트랙트만 호출 가능");
        _;
    }
    function setToken(address addr) external onlyOwner {
        HallymToken = addr;
    }

    function pushStatus(string calldata _grade, uint _times, uint _sum, uint _rate) external onlyOwner {
        status.push(GradeStatus({
            grade: _grade,
            times: _times,
            sum: _sum,
            rate: _rate
        }));
    }

    function editStatus(uint index, string calldata _grade, uint _times, uint _sum, uint _rate) external onlyOwner {
        if(index < status.length) {
            status[index].grade = _grade;
            status[index].times = _times;
            status[index].sum = _sum;
            status[index].rate = _rate;
        }
    }
    
    function updateHistory(address member, uint amount) external onlyToken {
        tradingHistory[member].times++;
        tradingHistory[member].sum += amount;

        uint index;
        for(uint i = 0; i < status.length; i++) {
            if(tradingHistory[member].times >= status[i].times && tradingHistory[member].sum >= status[i].sum) {
                index = i;
            }
        }
        tradingHistory[member].statusIndex = index;
    }

    function getCashbackRate(address member) external view returns(uint) {
        if(status.length == 0) return 0;
        return status[tradingHistory[member].statusIndex].rate;
    }
}

// Token Contract
contract HLToken is Owned {
    // 추가 기능 ( pause / unpause )
    bool public paused; // Default : false

    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;

    Members public members;

    mapping(address => uint) public balanceOf;
    mapping(address => bool) public blackList;
    mapping(address => uint) public cashbackRate;

    modifier whenNotPaused() {
        require(!paused, unicode"일시정지 상태");
        _;
    }

    event Paused(address by);
    event Unpaused(address by);

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

    function setMembers(Members _members) external onlyOwner {
        members = _members;
    }

    function transfer(address to, uint amount) external whenNotPaused {
        // Check blacklist
        require(blackList[to] != true, unicode"받는 주소 블랙리스트");
        require(blackList[msg.sender] != true, unicode"보내는 주소 블랙리스트");

        // Calculate Cashback
        uint cashback = 0;
        if(address(members) != address(0)) {
            uint rate = members.getCashbackRate(msg.sender);
            cashback = (amount * rate) / 100;
            members.updateHistory(msg.sender, amount);
        }

        uint payout = amount - cashback;

        require(balanceOf[msg.sender] >= payout, unicode"잔액부족");
        require(balanceOf[to] + payout >= balanceOf[to], unicode"부정송금");
        
        balanceOf[msg.sender] -= payout;
        balanceOf[to] += payout;

        
        emit Cashback(msg.sender, to, cashback);
        emit Transfer(msg.sender, to, payout);
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

    // 추가 기능
    function pause() external onlyOwner {
        require(!paused, unicode"이미 일시정지 상태");
        paused = true;
        emit Paused(msg.sender);
    }

    function unPause() external onlyOwner {
        require(paused, unicode"일시정지 상태가 아님");
        paused = false;
        emit Unpaused(msg.sender);
    }
}

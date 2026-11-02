// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract SavingWallet{
    // 1. 적금 지갑의 소유자 (이더를 받을 수 있어야 함)
    address payable public owner;

    // 2. 목표 금액 (wei 단위, 외부에서 직접 볼 수 없게)
    uint private goal;

    // 3. 생성자
    //    - _goal: ETH 단위로 받은 목표 금액
    //    - owner 설정, ETH 단위로 입력 받은 goal을 wei 단위로 변환하여 저장
    constructor(uint _goal) {
        owner = payable(msg.sender);
        goal = _goal * 10 ** 18;
    }

    // 4. 이더 입금을 받기 위한 receive 함수
    receive() external payable { }

    // 5. 목표 금액에 도달했는지 확인하는 내부 함수
    //    - 현재 컨트랙트 잔고가 goal 이상이면 true 반환
    function isReachGoal() internal view returns (bool) {
        return address(this).balance >= goal;
    }

    // 6. 목표까지 남은 금액을 int 로 반환
    //    - 남은 금액 = goal - 현재잔고
    //    - 이미 목표를 넘었으면 0 반환
    function checkRemain() public view returns (int) {
        if (isReachGoal()) {
            return 0;
        }
        return int(goal) - int(address(this).balance);
    }

    // 7. 출금 함수
    //    - owner만 호출 가능
    //    - 목표 금액에 도달했을 때만 전체 잔액을 owner에게 전송
    function withdraw() public {
        // msg.sender가 owner가 아니면 그냥 종료
        if (msg.sender != owner) {
            return;
        }

        // 목표를 달성하지 못했으면 그냥 종료
        if (!isReachGoal()) {
            return;
        }

        // 현재 잔액 전부를 owner에게 전송
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    // 8. 소유권 이전 함수
    //    - owner만 호출 가능
    //    - 전달된 newOwner로 owner를 변경
    function changeOwner(address newOwner) public {
        if (msg.sender == owner) {
            owner = payable(newOwner);
        }
    }
}

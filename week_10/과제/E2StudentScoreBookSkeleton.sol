// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract StudentScoreBook {
    struct Student{
        string name;
        uint[] scores;
    }
    
    mapping(uint => Student) private students; // 학번 => Student
    address public teacher;

    event StudentAdded(uint id, string name);

    // 0. 선생님만 점수/학생을 수정할 수 있도록 하는 기본 modifier
    modifier onlyTeacher() {
        require(teacher == msg.sender, unicode"권한 없음");
        _;
    }

    modifier studentsExists(uint id) {
        require(bytes(students[id].name).length > 0, unicode"존재하지 않은 학생");
        _;
    }

    constructor() {
        teacher = msg.sender;
    }

    // 1. 학생 등록
    function addStudent(uint id, string calldata _name) external onlyTeacher {
        // TODO:
        // 이미 해당 학번이 등록되어 있지 않은지 확인
        // (HINT) name 이 비어 있으면(길이 0) 아직 등록되지 않은 상태라고 가정
        require(bytes(students[id].name).length == 0, unicode"이미 등록된 학번");
        // 매핑에서 키(id)에 해당하는 Student 구조체의 name에 _name을 저장
        require(bytes(_name).length > 0, unicode"이름이 비어있음");
        students[id].name = _name;
        // 이벤트 로깅: (학번, 이름) 등록
        emit StudentAdded(id, _name);
    }

    // 2. 점수 추가
    function addScore(uint id, uint _score) external onlyTeacher studentsExists(id){
        // TODO:
        // 학생 존재 여부를 require로 검사 (Modifier 생성해서 처리 가능)
        // 0~100점만 허용하도록 require 작성
        require(_score <= 100, unicode"100점 이하만 입력 가능");
        // 매핑에서 키(id)에 해당하는 Student 구조체의 score 배열에 _score를 append
        students[id].scores.push(_score);
    }

    // 3. 학생 정보 조회
    function getStudent(uint id) external view returns (string memory name, uint[] memory scores) {
        // TODO:
        // 학생 존재 여부를 require로 검사
        require(bytes(students[id].name).length == 0 ,)
        // 학생 이름과 점수를 반환
    }

    // 4. 평균 점수 조회
    function getAverage(uint id) external view returns (uint avg) {
        // TODO:
        // 학생 존재 여부를 require로 검사
        // 점수가 하나도 없으면 에러
        // for 문을 이용하여 점수 합계 계산
        // 합계에 길이를 나누어 평균 반환
    }
}

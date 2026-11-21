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

    // 학생 존재 여부 검사 modifier (name 길이가 0이면 미등록)
    modifier studentExists(uint id) {
        require(bytes(students[id].name).length > 0, unicode"존재하지 않는 학생");
        _;
    }

    constructor() {
        teacher = msg.sender;
    }

    // 1. 학생 등록
    function addStudent(uint id, string calldata _name) external onlyTeacher {
        require(bytes(students[id].name).length == 0, unicode"이미 등록된 학번");
        require(bytes(_name).length > 0, unicode"이름이 비어 있음");
        students[id].name = _name;
        emit StudentAdded(id, _name);
    }

    // 2. 점수 추가
    function addScore(uint id, uint _score) external onlyTeacher studentExists(id) {
        require(_score <= 100, unicode"100점 이하만 입력 가능");
        students[id].scores.push(_score);
    }

    // 3. 학생 정보 조회
    function getStudent(uint id) external view studentExists(id) returns (string memory name, uint[] memory scores) {
        Student storage s = students[id];
        return (s.name, s.scores);
    }

    // 4. 평균 점수 조회
    function getAverage(uint id) external view studentExists(id) returns (uint avg) {
        uint[] storage scores = students[id].scores;
        require(scores.length > 0, unicode"점수가 없음");

        // 점수 합계 계산
        uint sum = 0;
        for (uint i = 0; i < scores.length; i++) {
            sum += scores[i];
        }
        return sum / scores.length;
    }
}

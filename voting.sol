// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vote{
    address electionCommision;
    address public winner;

    struct Voter{
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate{
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }

    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;  //to set start time of election
    uint endTime;  //to set stoptime

    mapping (uint => Voter) voterDetails; //for fetching voter details
    mapping (uint => Candidate) candidateDetails; //for fetching candaidate details
    bool stopVoting;

    constructor (){
        electionCommision = msg.sender;
    }

    modifier isVotingOver(){
        require(endTime > block.timestamp && stopVoting, "Voting is over");
        _;
    }

    modifier onlyCommissioner(){
        require(electionCommision == msg.sender, "Not from election commision");
        _;
    }

    function candidateRegister(string calldata _name, string calldata _party, uint _age, string calldata _gender) external{
        require(_age >=18, "Invalid age");
        require(msg.sender != electionCommision, "election commision can't register as candidate");
        require(nextCandidateId < 3, "candidate regestration is full");
        require(candidateVerification(msg.sender) == true, "Candidate already registered");
        candidateDetails[nextCandidateId] = Candidate(_name, _party, _age, _gender,nextCandidateId, msg.sender, 0);
        nextCandidateId++;
    }
    // for preventing double registration
    function candidateVerification(address _person) internal view returns (bool){
        for(uint i = 1; i < nextCandidateId; i++){
            if(candidateDetails[i].candidateAddress == _person){
                return false;
            }
        }
        return true;
    }
    

    function candidateList() public view returns (Candidate[] memory){
        Candidate[] memory array = new Candidate[](nextCandidateId -1);
        for(uint i=1; i< nextCandidateId; i++){
            array[i - 1] = candidateDetails[i];
        }

        return array;
}

    function voterRegistration(string calldata _name, uint _age, string calldata _gender) external {
         require(_age >=18, "Invalid age");
         require(voterVerification(msg.sender) == true,"invalid input");
         voterDetails[nextVoterId] = Voter(_name, _age, nextVoterId, _gender, 0, msg.sender);
         nextVoterId++;
}
    //for preventing double registration
    function voterVerification(address _person)internal view returns(bool){
        for(uint i =1; i< nextVoterId; i++){
            if(voterDetails[i].voterAddress == _person){
                return false;
            }
        }
        return true;
}

    function voterList() public view returns(Voter[] memory){
        Voter[] memory array = new Voter[](nextVoterId - 1);
        for(uint i = 1; i < nextVoterId; i++){
            array[i -1] = voterDetails[i];
        }
        return array;
}

    function vote(uint _voteId, uint _id)external isVotingOver{
        require(voterDetails[_voteId].voteCandidateId==0, "already voted");
        require(voterDetails[_voteId].voterAddress == msg.sender, "invlaid voter");
        require(startTime != 0, "voting not started yet");
        require(nextCandidateId == 3, "Candidate registration not completed yet");
        require(_id > 0 && _id < 3, "invalid id");
        voterDetails[_voteId].voteCandidateId = _id;
        candidateDetails[_id].votes++;
    }

    function voteTime(uint _startTime, uint _endTime) external onlyCommissioner(){
        startTime = block.timestamp + _startTime;
        endTime = startTime + _endTime;
        stopVoting = false;
    }

    function votingStatus() public view returns(string memory){
        if(startTime == 0){
            return "Voting has not started";
        }else if((startTime != 0 && endTime > block.timestamp) && stopVoting == false){
            return "Voting in progress";
        }else{
            return "voting ended";
        }
    }

    function result() external onlyCommissioner() returns(address){
        Candidate storage candidate1 = candidateDetails[1];
        Candidate storage candidate2 = candidateDetails[2];
        if(candidate1.votes > candidate2.votes){
            winner = candidate1.candidateAddress;
        }else{
            winner = candidate2.candidateAddress;
        }
        return winner;
    }
    //to stop in emergency
    function emergency() public onlyCommissioner(){
        stopVoting = true;
    }
}
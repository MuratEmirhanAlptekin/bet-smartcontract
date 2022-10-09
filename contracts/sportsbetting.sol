// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "./Ownable.sol";

contract sportsbetting is Ownable{

    event NewBet(address addr, uint amount, Team team);

    struct Team {
        string teamname ;
        uint totalbet;
    }

    struct bet {
        string name;
        address addr;
        uint amount;
        Team team;
    }
    bet[] public bets;
    Team[] public teams ;
    address payable Owner;
    mapping (address => uint) public betAmounts;
    uint public total;

    constructor() payable {
        Owner = payable(msg.sender);
        teams.push(Team("team1", 0));
        teams.push(Team("team2", 0));
    }

    function createTeam (string memory _name) public {
        teams.push(Team(_name, 0));
    }

    function getTotalBetAmount (uint _team) public view returns (uint) {
    return teams[_team].totalbet;
    }

    function createBet (string memory _name, uint _team) external payable { 
        require (msg.sender != Owner, "owner is not allowed to make a bet");
        require (betAmounts[msg.sender] == 0, "Only one bet is allowed");
        betAmounts[msg.sender] = msg.value;
        bets.push(bet(_name, msg.sender, msg.value, teams[_team]));
        if (_team == 0) {
            teams[0].totalbet += msg.value;
        }
         if (_team == 1) {
            teams[1].totalbet += msg.value;
        }
        
        (bool sent, ) = Owner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        total += msg.value;
        emit NewBet(msg.sender, msg.value, teams[_team]);
        }
    
    function winningTeam(uint _team) public payable onlyOwner() {
        uint slice;
        if (_team == 0){
            for (uint i = 0; i < bets.length; i++){
                if (sha256(abi.encodePacked((bets[i].team.teamname))) == sha256(abi.encodePacked("team1"))){
                    address payable receiver = payable(bets[i].addr);
                    slice = (bets[i].amount * (10000 + (getTotalBetAmount(1) * 10000 / getTotalBetAmount(0)))) / 10000;
                    (bool sent,) = receiver.call{ value: slice }("");
                    require(sent, "Failed to send Ether1");
                }
            }
        }
        if (_team == 1){
            for (uint i = 0; i < bets.length; i++){
                if (sha256(abi.encodePacked((bets[i].team.teamname))) == sha256(abi.encodePacked("team2"))){
                    address payable receiver = payable(bets[i].addr);
                    slice = (bets[i].amount * (10000 + (getTotalBetAmount(0) * 10000 / getTotalBetAmount(1)))) / 10000;
                    (bool sent,) = receiver.call{ value: slice }("");
                    require(sent, "Failed to send Ether2");
                }
            }
        }
        total = 0;
        teams[0].totalbet = 0;
        teams[1].totalbet = 0;

        for (uint i = 0; i < bets.length; i++) {
            betAmounts[bets[i].addr] = 0;
        }


    }
}

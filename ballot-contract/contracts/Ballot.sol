// // SPDX-License-Identifier: Unlicensed
// pragma solidity >=0.7.0 <0.9.0;
// /// @title Online Voting
// contract Ballot {

//     struct Voter {                     
//         uint weight;        // Voting weight, chairperson = 2, everyone else = 1
//         bool voted;         // Whether one voted
//         uint vote;          // Proposal # one voted on
//     }
//     struct Proposal {                  
//         uint voteCount;     // Total votes of a proposal
//     }

//     address chairperson;
//     mapping(address => Voter) voters;  
//     Proposal[] proposals;

//     enum Phase {Init, Regs, Vote, Done}
//     Phase public currentPhase = Phase.Init;
    
//     // events
//     //event VoteInit();
//     event RegsStarted();
//     event VoteStarted();
//     event VoteDone(uint winningProposal);

//     // modifiers
//     modifier onlyChair() {
//         require(msg.sender == chairperson, "Only chairperson can perform this operation");
//         _;
//     }
     
//     modifier validVoter() {
//         require(voters[msg.sender].weight > 0, "Not a Registered Voter");
//         _;
//     }

//     modifier validPhase(Phase reqPhase) {
//         require(currentPhase == reqPhase, "Not the required phase");
//         _;
//     }

//     constructor (uint numProposals) {
//         chairperson = msg.sender;
//         voters[chairperson].weight = 2; // weight 2 for testing purposes
//         for (uint prop = 0; prop < numProposals; prop ++)
//             proposals.push(Proposal(0));
//         advancePhase();
//     }

//     function advancePhase() public onlyChair {
//         // If already in done phase, revert
//         if (currentPhase == Phase.Done) {
//             // currentPhase = Phase.Init;
//             revert("Voting was done");
//         } else {
//             // else, increment the phase
//             // Conversion to uint needed as enums are internally uints
//             uint nextPhase = uint(currentPhase) + 1;
//             currentPhase = Phase(nextPhase);
//         }

//         // Emit appropriate events for the new phase
//         if (currentPhase == Phase.Regs) emit RegsStarted();
//         if (currentPhase == Phase.Vote) emit VoteStarted();
//         if (currentPhase == Phase.Done) emit VoteDone(reqWinner());
//     }
     
//     function register(address voter) public validPhase(Phase.Regs) onlyChair {       
//         voters[voter].weight = 1;
//         voters[voter].voted = false;
//     }
   
//     function vote(uint toProposal) public validPhase(Phase.Vote) validVoter {      
//         Voter storage sender = voters[msg.sender];
        
//         require (!sender.voted, "Voter has already voted"); 
//         require (toProposal < proposals.length, "Proposal number over limit"); 
//         // if (sender.voted || toProposal >= proposals.length) revert();
        
//         sender.voted = true;
//         sender.vote = toProposal;   
//         proposals[toProposal].voteCount += sender.weight;
//     }

//     function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {       
//         uint winningVoteCount = 0;
//         for (uint prop = 0; prop < proposals.length; prop++) 
//             if (proposals[prop].voteCount > winningVoteCount) {
//                 winningVoteCount = proposals[prop].voteCount;
//                 winningProposal = prop;
//             }
//     }
// }

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CardGame is ERC721 {
    struct Card {
        uint256 value;
        address owner;
    }

    struct Player {
        address id;
    }

    struct MatchRecord {
        address winner;
        address loser;
        uint256 winner_card_id;
        uint256 loser_card_id;
        uint256 match_id;
    }

    struct awaiting_match {
        address userid;
        uint256 cardid;
    }

    address admin;

    mapping(address => Player) public players;
    mapping(uint256 => Card) public cards;
    
    MatchRecord[] MatchRecords;
    awaiting_match Awaiting_match;

    function register_player() public {
        require(players[msg.sender].id == address(0), "User already registered");
        players[msg.sender].id = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only chairperson can perform this operation");
        _;
    }

    constructor() ERC721("CardGame", "CGM") {
        admin = msg.sender;
    }

    function mintCard(uint256 cardId, uint256 cardValue) public {
        Card memory newCard = Card(cardValue, msg.sender);
        cards[cardId] = newCard;
    }

    function addCardToPlayer(uint256 cardId) public {
        require(players[msg.sender].id == msg.sender, "User not registered");
        require(cards[cardId].owner == address(0), "Card does not exist");
        require(ownerOf(cardId) == msg.sender, "Not card owner");

        uint256 cardValue = calculate_card_value(cardId);
        mintCard(cardId, cardValue);
    }


    function calculate_card_value(uint256 cardId) public returns (uint256) {
        return cardId; // TODO
    }

    function RandomMatch(uint256 cardId) public returns (uint256) {
        Card memory card = cards[cardId];
        require(card.owner == msg.sender, "Not your card!");
        if (Awaiting_match.userid == address(0)) {
            Awaiting_match.userid = msg.sender;
            Awaiting_match.cardid = cardId;
            return MatchRecords.length;
        }
        else {
            address winner;
            address loser;
            uint256 winner_card_id;
            uint256 loser_card_id;
            uint256 match_id = MatchRecords.length;
            if (card.value > cards[Awaiting_match.cardid].value) {
                winner = msg.sender;
                loser = Awaiting_match.userid;
                winner_card_id = cardId;
                loser_card_id = Awaiting_match.cardid;
            }
            else if (card.value < cards[Awaiting_match.cardid].value){
                winner = Awaiting_match.userid;
                loser = msg.sender;
                winner_card_id = Awaiting_match.cardid;
                loser_card_id = cardId;
            }
            else {
                winner = address(0);
                loser = address(0);
                winner_card_id = cardId;
                loser_card_id = Awaiting_match.cardid;
            }
            MatchRecord memory cur_match = MatchRecord(winner, loser, winner_card_id, loser_card_id, match_id);
            MatchRecords.push(cur_match);
            Awaiting_match.userid = address(0);
            Awaiting_match.cardid = 0;
            return match_id;
        }
    }
    

    function TestMatch(address player1Id, address player2Id, uint256 card1Id, uint256 card2Id) public view onlyAdmin returns (address) {

        Card memory card1 = cards[card1Id];
        require(card1.owner == player1Id, "Card1 Invalid");

        Card memory card2 = cards[card2Id];
        require(card2.owner == player2Id, "Card2 Invalid");

        if(card1.value > card2.value) {
            return player1Id;
        } else if(card2.value > card1.value) {
            return player2Id;
        } else {
            return address(0); // draw, no winner
        }
    }

    function view_result(uint256 matchid) public view returns (address winner) {       
        require(players[msg.sender].id == msg.sender, "User not registered");
        require(matchid < MatchRecords.length, "Invalid match ID");
        return MatchRecords[matchid].winner;
    }

}
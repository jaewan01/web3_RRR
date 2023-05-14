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

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CardGame is ERC721 {
    struct Card {
        uint256 id;
        uint256 value;
    }

    struct Player {
        address id;
        Card[] cards;
    }

    mapping(address => Player) public players;
    mapping(uint256 => Card) public cards;

    constructor() ERC721("CardGame", "CGM") {}

    function mintCard(uint256 cardId, uint256 value) public {
        Card memory newCard = Card(cardId, value);
        cards[cardId] = newCard;
        _mint(msg.sender, cardId);
    }

    function addCardToPlayer(uint256 cardId) public {
        require(_exists(cardId), "Card does not exist");
        require(ownerOf(cardId) == msg.sender, "Not card owner");
        players[msg.sender].cards.push(cards[cardId]);
    }

    function reqWinner(address player1Id, address player2Id, uint256 card1Id, uint256 card2Id) public view returns (address) {
        Player memory player1 = players[player1Id];
        Player memory player2 = players[player2Id];
        Card memory card1;
        Card memory card2;

        for(uint i = 0; i < player1.cards.length; i++) {
            if(player1.cards[i].id == card1Id) {
                card1 = player1.cards[i];
            }
        }

        for(uint i = 0; i < player2.cards.length; i++) {
            if(player2.cards[i].id == card2Id) {
                card2 = player2.cards[i];
            }
        }

        require(card1.id != 0 && card2.id != 0, "One of the cards does not exist");

        if(card1.value > card2.value) {
            return player1Id;
        } else if(card2.value > card1.value) {
            return player2Id;
        } else {
            return address(0); // draw, no winner
        }
    }
}
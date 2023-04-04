// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.0 <0.9.0;
/// @title Online Voting
contract Ballot {

    struct Voter {                     
        uint weight;        // Voting weight, chairperson = 2, everyone else = 1
        bool voted;         // Whether one voted
        uint vote;          // Proposal # one voted on
    }
    struct Proposal {                  
        uint voteCount;     // Total votes of a proposal
    }

    address chairperson;
    mapping(address => Voter) voters;  
    Proposal[] proposals;

    enum Phase {Init, Regs, Vote, Done}
    Phase public currentPhase = Phase.Init;
    
    // events
    //event VoteInit();
    event RegsStarted();
    event VoteStarted();
    event VoteDone(uint winningProposal);

    // modifiers
    modifier onlyChair() {
        require(msg.sender == chairperson, "Only chairperson can perform this operation");
        _;
    }
     
    modifier validVoter() {
        require(voters[msg.sender].weight > 0, "Not a Registered Voter");
        _;
    }

    modifier validPhase(Phase reqPhase) {
        require(currentPhase == reqPhase, "Not the required phase");
        _;
    }

    constructor (uint numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight 2 for testing purposes
        for (uint prop = 0; prop < numProposals; prop ++)
            proposals.push(Proposal(0));
        advancePhase();
    }

    function advancePhase() public onlyChair {
        // If already in done phase, revert
        if (currentPhase == Phase.Done) {
            // currentPhase = Phase.Init;
            revert("Voting was done");
        } else {
            // else, increment the phase
            // Conversion to uint needed as enums are internally uints
            uint nextPhase = uint(currentPhase) + 1;
            currentPhase = Phase(nextPhase);
        }

        // Emit appropriate events for the new phase
        if (currentPhase == Phase.Regs) emit RegsStarted();
        if (currentPhase == Phase.Vote) emit VoteStarted();
        if (currentPhase == Phase.Done) emit VoteDone(reqWinner());
    }
     
    function register(address voter) public validPhase(Phase.Regs) onlyChair {       
        voters[voter].weight = 1;
        voters[voter].voted = false;
    }
   
    function vote(uint toProposal) public validPhase(Phase.Vote) validVoter {      
        Voter storage sender = voters[msg.sender];
        
        require (!sender.voted, "Voter has already voted"); 
        require (toProposal < proposals.length, "Proposal number over limit"); 
        // if (sender.voted || toProposal >= proposals.length) revert();
        
        sender.voted = true;
        sender.vote = toProposal;   
        proposals[toProposal].voteCount += sender.weight;
    }

    function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {       
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop++) 
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
    }
}
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CardGame is ERC721 {
    struct Card {
        uint256 value;
        address owner;
    }

    struct Player {
        address id;
        mapping(uint256 => bool) cardsOwned;
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
        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }

    constructor() ERC721("CardGame", "CGM") {
        admin = msg.sender;
    }

    function assignValue(uint256 cardId) internal view returns (uint256) {
        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, cardId))) % 100 + 1;
        return randomValue;
    }

    function mintCard(uint256 cardId) public {
        require(cards[cardId].owner == address(0), "Card already exists");
        uint256 cardValue = assignValue(cardId);
        Card memory newCard = Card(cardValue, msg.sender);
        cards[cardId] = newCard;
        _mint(msg.sender, cardId);
    }

    function addCardToPlayer(uint256 cardId) public {
        require(players[msg.sender].id == msg.sender, "User not registered");
        require(cards[cardId].owner == msg.sender, "Not card owner");
        players[msg.sender].cardsOwned[cardId] = true;
    }


    // function calculate_card_value(uint256 cardId) public returns (uint256 cardId) {
    //     return cardId; // TODO
    // }

    function RandomMatch(uint256 cardId) public returns (uint match_id) {
        Card memory card = cards[cardId];
        require(card.owner == msg.sender, "Not your card!");
        if (Awaiting_match.userid == address(0)) {
            Awaiting_match.userid = msg.sender;
            Awaiting_match.cardid = cardId;
            match_id = MatchRecords.length;
            return match_id;
        }
        else {
            address winner;
            address loser;
            uint256 winner_card_id;
            uint256 loser_card_id;
            match_id = MatchRecords.length;
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

    function CurrentMatchID() public view returns (uint match_id)
    {
        uint match_id = MatchRecords.length;
        return match_id;

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
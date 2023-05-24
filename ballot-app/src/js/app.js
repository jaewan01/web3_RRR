App = {
  web3Provider: null,
  contracts: {},
  names: new Array(),
  url: 'http://127.0.0.1:7545',
  chairPerson:null,
  currentAccount:null,

  eventPhases: {
    "VoteInit": { 'id': 0, 'text': "Voting Not Started" },
    "RegsStarted": { 'id': 1, 'text': "Registration Started" },
    "VoteStarted": { 'id': 2, 'text': "Voting Started" },
    "VoteDone": { 'id': 3, 'text': "Voting Ended" }
  },

  votingPhases: {
    "0": "Voting Not Started",
    "1": "Registration Started",
    "2": "Voting Started",
    "3": "Voting Ended"
  },

  init: function() {
    $.getJSON('../proposals.json', function(data) {
      var proposalsRow = $('#proposalsRow');
      var proposalTemplate = $('#proposalTemplate');

      for (i = 0; i < data.length; i ++) {
        proposalTemplate.find('.panel-title').text(data[i].name);
        proposalTemplate.find('img').attr('src', data[i].picture);
        proposalTemplate.find('.btn-vote').attr('data-id', data[i].id);

        proposalsRow.append(proposalTemplate.html());
        App.names.push(data[i].name);
      }
    });
    return App.initWeb3();
  },

  initWeb3: function() {
        // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fallback to the TestRPC
      App.web3Provider = new Web3.providers.HttpProvider(App.url);
    }
    web3 = new Web3(App.web3Provider);
    ethereum.enable();

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('CardGame.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      
      
      // TODO 수정해야 할 곳
      var cardgameArtifact = data;
      App.contracts.cardgame = TruffleContract(cardgameArtifact);
      // Set the provider for our contract
      App.contracts.cardgame.setProvider(App.web3Provider);

      web3.eth.defaultAccount = web3.eth.coinbase;
      App.currentAccount = web3.eth.coinbase;
      jQuery('#current_account').text(App.currentAccount);
  
      App.getCurrentPhase();
      App.getChairperson();
  
      return App.bindEvents();
    });
  },

  bindEvents: function() {
    // $(document).on('click', '.btn-vote', App.handleVote);
    $(document).on('click', '#btn-mint', function(){ var cardid = $('#enter_cardid').val(); App.handleMintCard(cardid);});
    // $(document).on('click', '#change-phase', App.handlePhase);
    $(document).on('click', '#win-count', App.handleWinner); //lookup winner 로 사용해야 할 듯
    $(document).on('click', '#register', function(){ var ad = $('#enter_address').val(); App.handleRegister(ad); });
  },

  getCurrentPhase: function() {
    App.contracts.cardgame.deployed().then(function(instance) {
      return instance.currentPhase();
    }).then(function(result) {
      App.currentPhase = result;
      var notificationText = App.votingPhases[App.currentPhase];
      console.log(App.currentPhase);
      console.log(notificationText);
      $('#phase-notification-text').text(notificationText);
      console.log("Phase set");
    })
  },

  getChairperson : function(){
    App.contracts.cardgame.deployed().then(function(instance) {
      return instance;
    }).then(function(result) {
      App.chairPerson = result.constructor.currentProvider.selectedAddress.toString();
      App.currentAccount = web3.eth.coinbase;
      if(App.chairPerson != App.currentAccount){
        jQuery('#address_div').css('display','none');
        jQuery('#register_div').css('display','none');
      }else{
        jQuery('#address_div').css('display','block');
        jQuery('#register_div').css('display','block');
      }
    })
  },

  handleMintCard: function (cardid) {
    var cardgameInstance;
    App.contracts.cardgame.deployed().then(function(instance) {
      cardgameInstance = instance;
      // card mint 하게 만들었음
      return cardgameInstance.handleMintCard(cardid);
    }).then(function(result, err){
        if(result){
            if(parseInt(result.receipt.status) == 1)
            alert(addr + " minting done successfully")
            else
            alert(addr + " minting not done successfully due to revert")
        } else {
            alert(addr + " minting failed")
        }   
    });
  },

  //Function to show the notification of voting phases
  showNotification: function (phase) {
    var notificationText = App.eventPhases[phase];
    $('#phase-notification-text').text(notificationText.text);
  },

  handleRegister: function(addr){
    var voteInstance;
    App.contracts.cardgame.deployed().then(function(instance) {
      voteInstance = instance;
      // register 대신 register player 넣었음
      return voteInstance.register_player(addr);
    }).then(function(result, err){
        if(result){
            if(parseInt(result.receipt.status) == 1)
            alert(addr + " registration done successfully")
            else
            alert(addr + " registration not done successfully due to revert")
        } else {
            alert(addr + " registration failed")
        }   
    });
},

  handleWinner : function() {
    console.log("To get winner");
    var voteInstance;
    App.contracts.cardgame.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.reqWinner();
    }).then(function(res){
    console.log(res);
      alert(App.names[res] + "  is the winner ! :)");
    }).catch(function(err){
      console.log(err.message);
    })
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

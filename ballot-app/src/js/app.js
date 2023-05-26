App = {
  web3Provider: null,
  contracts: {},
  names: new Array(),
  url: 'http://127.0.0.1:7545',
  admin:null,
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

      $('#current-winner-text').text('no winner');
      $('#match-id-text').text('no match');
  
      App.getAdmin();
  
      return App.bindEvents();
    });
  },

  bindEvents: function() {
    $(document).on('click', '#mintcard', function(){ var cardid = $('#enter_cardid').val(); App.handleMintCard(cardid);});
    $(document).on('click', '#view-result', function(){ var matchid = $('#enter_matchid').val(); App.handleViewResult(matchid);});
    $(document).on('click', '#register', function(){ var ad = $('#enter_address').val(); App.handleRegister(ad); });
    $(document).on('click', '#random-match', function(){ var cardid = $('#enter_cardid').val(); App.handleRandomMatch(cardid); });
  },

  getAdmin : function(){
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
      // card mint 하게 만들었음 ;; 아니잖아 안선호
      return cardgameInstance.mintCard(cardid);
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

  showNotificationWinner: function (phase) {
    var notificationText = App.eventPhases[phase];
    $('#current-winner-text').text(notificationText.text);
  },

  showNotificationMatchID: function (phase) {
    var notificationText = App.eventPhases[phase];
    $('#match-id-text').text(notificationText.text);
  },

  handleRegister: function(addr){
    var cardgameInstance;
    App.contracts.cardgame.deployed().then(function(instance) {
      cardgameInstance = instance;
      // register 대신 register player 넣었음
      return cardgameInstance.register_player(addr);
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

  handleViewResult: function(matchid){
    var cardgameInstance;
    App.contracts.cardgame.deployed().then(function(instance) {
      cardgameInstance = instance;
      return cardgameInstance.view_result(matchid);
    }).then(function(res){
      App.showNotificationMatchID(matchid)
      App.showNotificationWinner(res.logs[0].event)
      console.log(res);
      alert(App.names[res] + "  is the winner ! :)");
    }).catch(function(err){
      console.log(err.message);
    })
},

  handleRandomMatch: function(cardid){
    var cardgameInstance;
    App.contracts.cardgame.deployed().then(function(instance) {
      cardgameInstance = instance;
      return cardgameInstance.RandomMatch(cardid);
    }).then(function(res){
      App.showNotificationMatchID(res.logs[0].event)
      console.log(res);
      alert("Match ID : " + App.names[res]);
    }).catch(function(err){
      console.log(err.message);
    })
  },

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

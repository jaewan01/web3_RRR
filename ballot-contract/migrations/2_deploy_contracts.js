
// cardgame 이라는 contract 를 쓰기 때문에 이렇게 고쳐둠
var CardGame = artifacts.require("CardGame");

module.exports = function(deployer) {
  // cardgame 은 parameter 이 없음.
  deployer.deploy(CardGame);
};

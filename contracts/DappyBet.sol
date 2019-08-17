pragma solidity 0.5.1;
pragma experimental ABIEncoderV2;

contract DappyBet{
    
    modifier onlyOwner(){
        
        require(msg.sender == owner);
        _;
    }
    
    
    event BetPaid(address recipient, uint amount, uint gameId);
    event BetStaked(address staker, uint amount, uint betId);
    event TeamCreated(uint teamId, string teamName);
    event GameCreated(uint gameId, uint timestamp);
    
    
    struct Team{
        uint id;
        string name;
    }
    
    struct Game{
        
        uint id;
        Team[] involvedTeams;
        uint lockTime;
        bool active;
        uint winner;
        //mapping(uint => uint) scores;
        GameStatus status;
    }
    
    struct Bet{
        
        uint amount;
        address staker;
        uint gameId;
        uint betOn; //teamId;
        bool paid;
    }
    
    struct GameResults{
        
        uint gameId;
        uint won;
        uint[] scores;
        uint timestamp;
    }
    
    enum GameStatus{Open, Locked}
    
    address payable owner;
    
    uint public teamsCount;
    uint public gamesCount;
    
    Game[] public games;
    mapping(uint => GameResults) public gamesResults;
    mapping(uint => Game) public gamesMapping;
    mapping(uint => uint) public matchStakesCount;
    
    mapping(address => mapping(uint => uint)) public gamersBalances;
    
    mapping(uint => Bet[]) public gameBets;

    mapping(uint => Team) teamsIdMapping;
    
    mapping(uint => bool) teamExist;

    mapping(uint => bool) gameIdValid;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function() external payable{}
    
    function createTeam(string memory name) public onlyOwner returns(bool){
        
        teamsCount++;
        Team storage team = teamsIdMapping[teamsCount];
        team.id = teamsCount;
        team.name = name;
        teamExist[teamsCount] = true;
        emit TeamCreated(teamsCount, team.name);

        return true;
    }
    
    function isValidGamesId(uint gameId) public view returns(bool){
         
         return gameIdValid[gameId];
         
     }
    
    function createGame(uint locktime, uint[] memory _teams ) public onlyOwner returns(bool){

        gamesCount++;
        
        Game storage game = gamesMapping[gamesCount];
        game.id = gamesCount;
        game.active = true;
        game.status = GameStatus.Open;
        game.lockTime = locktime;
        
        for(uint i = 0; i < _teams.length; i++){
            
           require(teamExists(_teams[i]), "This team does not exist");
           game.involvedTeams.push(getTeamById(_teams[i])) ; 
           
        }
        gameIdValid[gamesCount] = true;
        
        emit GameCreated(gamesCount, now);

        return true;
    }
    
    function getGameFullDetails(uint gameId) public view returns(Game memory){
        
        Game memory game =  gamesMapping[gameId];
        return game;
    }
    
    function getGamesCount() public view returns(uint){
        
        return gamesCount;
    }
    
    function getTeamsCount() public view returns(uint){
        
        return teamsCount;
    }

    function getTeamById(uint teamId) public view returns(Team memory team){
        
        Team memory team = teamsIdMapping[teamId];
        return team;
    }

    function isGameActive( uint id) public view returns(bool){
        
        Game memory game = gamesMapping[id];
        
        return game.active;
    }

    function teamExists(uint teamId) public view returns(bool){
    
        return teamExist[teamId];
    }
  
    function setGameResults(uint _gameId, uint winner, uint[] memory scores) public onlyOwner returns(bool){
        
        Game storage game = gamesMapping[_gameId];
        game.winner = winner;
        game.active = false;
        game.status = GameStatus.Locked;
        GameResults storage result = gamesResults[_gameId];
        result.won = winner;
        result.gameId = _gameId;
        result.scores = scores;
        result.timestamp = now;
        return true;
     }
     
     function getWinnerTeam(uint _gameId) public view returns(uint){
         
         require(isValidGamesId(_gameId), "Invalid game Id provided");
         GameResults memory result = gamesResults[_gameId];
         return result.won;
     }
     
     function getContractBalance() public view onlyOwner returns(uint){
         
         return address(this).balance;
     }
     
     function getContractAddr() public view returns(address){
        
         return address(this);
     }
    
     function getOwner() public view returns(address){
         
         return owner;
     }
     

    
    function bet(uint gameId, uint _teamId) public payable returns(bool, uint _betId){
        
        require(msg.value > 0, "You must send your amount to stake");
        require(isValidGamesId(gameId), "Invalid game Id");
        require(isGameActive(gameId), "You can only bet on active games");
        require(teamExists(_teamId), "Invalid team Id provided");
        
        
        Game memory game = gamesMapping[gameId];
        
        //require statement needs to be corrected to a less than sign
        require( now > game.lockTime, "Game already in progress");
        
        Bet memory bet;
        
        bet.staker = msg.sender;
        
        bet.gameId = game.id;
        
        bet.amount = uint(msg.value);
        
        bet.betOn = _teamId;
        
        bet.paid = false;
        
        matchStakesCount[gameId] += 1;

        gamersBalances[msg.sender][gameId] += uint(bet.amount);
        
        gameBets[gameId].push(bet);
        
        uint betId = gameBets[gameId].length -1 ;
        emit BetStaked(msg.sender, bet.amount, betId);

        return (true, betId);
        
    }
    
    function getBetById(uint _gameId ,uint _betId) public view returns(Bet memory bet){
        
          bet = gameBets[_gameId][_betId];
    }
    
    function getGameResults(uint gameId) public view returns(GameResults memory){
        
        require(isValidGamesId(gameId), "Invalid game Id provided");
        GameResults memory result = gamesResults[gameId];
        return result;
        
    }
    
    function getGameBets(uint gameId) public view returns(Bet[] memory){
        
        require(isValidGamesId(gameId), "Invalid game Id provided");
        Bet[] memory bets = gameBets[gameId];
        return bets;
    }
    
    function getGameBetWinnersCount(uint gameId, uint wonTeam) public view returns(uint){
        
        require(isValidGamesId(gameId), "Invalid game Id provided");
        uint count;
        Bet[] memory allBets = gameBets[gameId];
        
        for(uint i = 0; i < allBets.length; i++){
            Bet memory bet = allBets[i];
            
            if(bet.betOn == wonTeam) count += 1;
        }
        
       return count;
    }
    
        
    function payOutWinners(uint _gameId) public payable onlyOwner returns(bool){
        
        require(isValidGamesId(_gameId), "Invalid game Id provided");
        require(!isGameActive(_gameId), " You can only request payment after game is over");
        
        GameResults memory gameResult = gamesResults[_gameId];
        
        Bet[] memory allBets = gameBets[_gameId];
        
        for(uint i = 0; i <= allBets.length; i++){
            
            Bet memory bet = allBets[i];
            
            address staker = bet.staker;
            uint160 stakerInt = uint160(staker);
            address payable betStaker = address(stakerInt);
            
            require(gamersBalances[betStaker][_gameId] > 0, "Your stake cannot be  0 ");
            
            uint amountToPay = bet.amount * 2;
            
            require(!bet.paid, "Bet already paid out");
            
            if(bet.betOn != gameResult.won ){
                
                continue;
                
            }else{
                
                require(amountToPay < address(this).balance, "Inufficient balance please try again later");
                betStaker.transfer(amountToPay);
                gamersBalances[betStaker][_gameId] = 0;
                bet.paid = true;

              
            }
            emit BetPaid( betStaker,  amountToPay, _gameId);
            return true;
        }

        
   }
    
    function withdraw() public payable onlyOwner {
        
        owner.transfer(address(this).balance);
    }
    
}
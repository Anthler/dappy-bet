pragma solidity 0.5.1;
pragma experimental ABIEncoderV2;

contract DappyBet{
    
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
    
    // Enums
    
    enum GameStatus{Open, Locked}
    
    //Structs
    
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
    
    //Events
    
    event BetPaid(address recipient, uint amount, uint gameId);
    event BetStaked(address staker, uint amount, uint betId);
    event TeamCreated(uint teamId, string teamName);
    event GameCreated(uint gameId, uint timestamp);
    
    //Function modifiers
    
    modifier onlyOwner(){
        
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        
        owner = msg.sender;
    }
    
    function() external payable{}
    
    function createTeam(string memory _name) public onlyOwner returns(bool){
        
        teamsCount++;
        Team storage team = teamsIdMapping[teamsCount];
        team.id = teamsCount;
        team.name = _name;
        teamExist[teamsCount] = true;
        emit TeamCreated(teamsCount, team.name);
        return true;
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
    
    function bet(uint _gameId, uint _teamId) public payable returns(bool, uint _betId){
        
        require(msg.value > 0, "You must send your amount to stake");
        
        require(isValidGamesId(_gameId), "Invalid game Id");
        
        require(isGameActive(_gameId), "You can only bet on active games");
        require(teamExists(_teamId), "Invalid team Id provided");
        
        Game memory game = gamesMapping[_gameId];
        
        //needs to be corrected to a " < " less than sign
        // using " > " only for testing
        require( now > game.lockTime, "Game already in progress");
        
        Bet memory bet;
        bet.staker = msg.sender;
        bet.gameId = game.id;
        bet.amount = uint(msg.value);
        bet.betOn = _teamId;
        bet.paid = false;
        matchStakesCount[_gameId] += 1;
        gamersBalances[msg.sender][_gameId] += uint(bet.amount);
        gameBets[_gameId].push(bet);
        uint betId = gameBets[_gameId].length -1 ;
        emit BetStaked(msg.sender, bet.amount, betId);

        return (true, betId);
    }
    
    function setGameResults(uint _gameId, uint _winner, uint[] memory _scores) public onlyOwner returns(bool){
        
        Game storage game = gamesMapping[_gameId];
        game.winner = _winner;
        game.active = false;
        game.status = GameStatus.Locked;
        GameResults storage result = gamesResults[_gameId];
        result.won = _winner;
        result.gameId = _gameId;
        result.scores = _scores;
        result.timestamp = now;
        return true;
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
    
    function isValidGamesId(uint _gameId) public view returns(bool){
         
         return gameIdValid[_gameId];
     }
    
    function getGameFullDetails(uint _gameId) public view returns(Game memory){
        
        Game memory game =  gamesMapping[_gameId];
        return game;
    }
    
    function getGamesCount() public view returns(uint){
        
        return gamesCount;
    }
    
    function getTeamsCount() public view returns(uint){
        
        return teamsCount;
    }

    function getTeamById(uint _teamId) public view returns(Team memory team){
        
        Team memory team = teamsIdMapping[_teamId];
        return team;
    }

    function isGameActive( uint _id) public view returns(bool){
        
        Game memory game = gamesMapping[_id];
        return game.active;
    }

    function teamExists(uint _teamId) public view returns(bool){
    
        return teamExist[_teamId];
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
     
    function getBetById(uint _gameId ,uint _betId) public view returns(Bet memory bet){
        
          bet = gameBets[_gameId][_betId];
    }
    
    function getGameResults(uint _gameId) public view returns(GameResults memory){
        
        require(isValidGamesId(_gameId), "Invalid game Id provided");
        GameResults memory result = gamesResults[_gameId];
        return result;
        
    }
    
    function getGameBets(uint _gameId) public view returns(Bet[] memory){
        
        require(isValidGamesId(_gameId), "Invalid game Id provided");
        Bet[] memory bets = gameBets[_gameId];
        return bets;
    }
    
    function getGameBetWinnersCount(uint _gameId, uint _wonTeam) public view returns(uint){
        
        require(isValidGamesId(_gameId), "Invalid game Id provided");
        uint count;
        Bet[] memory allBets = gameBets[_gameId];
        
        for(uint i = 0; i < allBets.length; i++){
            Bet memory bet = allBets[i];
            
            if(bet.betOn == _wonTeam) count += 1;
        }
        
       return count;
    }
    
    function withdraw() public payable onlyOwner {
        
        owner.transfer(address(this).balance);
    }
    
}
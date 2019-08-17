import React, { Component } from "react";

import web3 from "../web3";
import DappyBetInstance from "../DappyBet";

class AllGames extends Component {
  state = {
    games: [],
    amount: 0,
    teamId: 0,
    gameResults: {},
    waiting: false,
    success: false,
    errorMessge: ""
  };

  async componentDidMount() {
    try {
      const gamesCount = await DappyBetInstance.methods.getGamesCount().call();
      for (var i = 1; i <= gamesCount; i++) {
        const game = await DappyBetInstance.methods
          .getGameFullDetails(i)
          .call();

        const gameJson = {
          id: game[0],
          teams: game[1],
          lockTime: game[2],
          active: game[3]
        };
        this.setState({ games: [...this.state.games, gameJson] });
        console.log(this.state.games);
      }
    } catch (error) {
      console.log(error.message);
    }
  }

  stakeBet = async gameId => {
    try {
      const gasLimit = web3.utils.toBN(3000000).toString();
      const accounts = await web3.eth.getAccounts();
      const teamId = this.state.teamId;
      await DappyBetInstance.methods.bet(gameId, teamId).send({
        from: accounts[0],
        value: web3.utils.toWei(this.state.amount.toString(), "ether"),
        gas: gasLimit
      });

      this.setState({ success: true });
    } catch (error) {
      console.log(error.message);
    }
  };

  updateAmount = event => {
    this.setState({ amount: event.target.value });
  };

  updateTeamId = event => {
    this.setState({ teamId: event.target.value });
    //console.log(event.target.value);
  };

  chosenTeam = event => {
    this.setState({ teamId: event.target.value });
  };

  async getGameResults(gameId) {
    const gameResult = await DappyBetInstance.methods.getGameResults(gameId);
    this.setState({ gameResults: gameResult });
  }
  render() {
    return (
      <div>
        <h4>UPCOMING GAMES </h4>
        <br />

        {this.state.success ? (
          <div>
            <div className="alert alert-success" role="alert">
              Your bet Was successfully staked
            </div>
          </div>
        ) : null}
        <div className="row justify-content-center">
          {this.state.games.map(game => {
            return (
              <div className="" key={game.id}>
                <div className="col-md-6">
                  <div className="card p-2 mb-5" style={{ width: "20rem" }}>
                    <div className="card-body">
                      <h5 className="card-title">TEAMS</h5>
                      {game.teams.map(team => {
                        return (
                          <div key={team.id}>
                            <h6 className="card-subtitle mb-1">{team.name}</h6>
                          </div>
                        );
                      })}

                      <hr />
                      <p className="card-text">
                        ACTIVE: {game.active ? "Yes" : "No"}
                      </p>
                      <p className="card-text">Lock Time: {game.lockTime}</p>
                      <div>
                        <select
                          onChange={this.updateTeamId}
                          className="form-control form-control-lg"
                        >
                          <option value={0}>Select Team</option>
                          {game.teams.map(team => {
                            return (
                              <option value={team.id} key={team.id}>
                                {team.name}
                              </option>
                            );
                          })}
                        </select>
                      </div>
                    </div>
                    <div className="form-group">
                      <div>
                        <input
                          type="text"
                          className="form-control"
                          placeholder="enter amount in Ether"
                          aria-label="amount"
                          aria-describedby="basic-addon1"
                          onChange={this.updateAmount}
                        />
                      </div>
                      <br />
                      <button
                        onClick={() => {
                          this.stakeBet(game.id);
                        }}
                        className=" btn btn-primary btn-block"
                      >
                        {" "}
                        Stake Bet{" "}
                      </button>
                    </div>
                  </div>
                  <br />
                </div>
              </div>
            );
          })}
        </div>
      </div>
    );
  }
}

export default AllGames;

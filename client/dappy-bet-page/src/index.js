import React from "react";
import ReactDOM from "react-dom";

import { Router, Route, Switch } from "react-router-dom";
import createBrowserHistory from "history/createBrowserHistory";

import "./index.css";
import App from "./App";
import Admin from "./components/Admin";
import "bootstrap/dist/css/bootstrap.min.css";

// const history = createBrowserHistory();

ReactDOM.render(
  <Router history={createBrowserHistory()}>
    <Switch>
      <Route exact path="/" component={App} />
      <Route path="/admin" component={Admin} />
    </Switch>
  </Router>,
  document.getElementById("root")
);

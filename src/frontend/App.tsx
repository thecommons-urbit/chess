import React from 'react';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import Urbit from '@urbit/http-api';
import useStore from './chessStore';
import { Board } from './pages/Board';
import { Menu } from './pages/Menu';
import { ChessChallengeUpdate, ChessGameInfo } from './ts/types';

function App() {
  const { setUrbit, receiveChallenge, receiveGame } = useStore();

  const init = async () => {

    const urbit = new Urbit('', '');
    urbit.ship = window.ship;

    setUrbit(urbit);

    await urbit.subscribe({
      app: 'chess',
      path: '/challenges',
      err: () => {},
      event: (data: ChessChallengeUpdate) => receiveChallenge(data),
      quit: () => {}
    });
  
    await urbit.subscribe({
      app: 'chess',
      path: '/active-games',
      err: () => {},
      event: (data: ChessGameInfo) => receiveGame(data),
      quit: () => {}
    });
  }

  React.useEffect(() => {
      init();
    }, []);

  return (
    <BrowserRouter basename={'/apps/chess'}>
      <Switch>
        <Route path="/game/:gameId" component={Board} />
        <Route exact path="/" component={Menu} />
      </Switch>
    </BrowserRouter>
  )
}

export default App;
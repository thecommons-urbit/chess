import React from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Urbit from '@urbit/http-api'
import useChessStore from '../ts/stores/chessStore'
import { ChessChallengeUpdate, ChessGameInfo } from '../ts/types/chess'
import { Main } from './Main'

export function App () {
  const { setUrbit, receiveChallenge, receiveGame } = useChessStore()

  const init = async () => {
    const urbit = new Urbit('', '')
    urbit.ship = window.ship

    setUrbit(urbit)

    await urbit.subscribe({
      app: 'chess',
      path: '/challenges',
      err: () => {},
      event: (data: ChessChallengeUpdate) => receiveChallenge(data),
      quit: () => {}
    })

    await urbit.subscribe({
      app: 'chess',
      path: '/active-games',
      err: () => {},
      event: (data: ChessGameInfo) => receiveGame(data),
      quit: () => {}
    })
  }

  // One time initialization hooks
  React.useEffect(
    () => { init() },
    [])

  return (
    <BrowserRouter basename={'/apps/chess'}>
      <Routes>
        <Route path="/:gameId" element={<Main />} />
        <Route path="/" element={<Main />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App

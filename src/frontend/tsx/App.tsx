import React from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Urbit from '@urbit/http-api'
import useStore from '../ts/chessStore'
import { ChessChallengeUpdate, ChessGameInfo } from '../ts/types'
import { Main } from './Main'

export function App () {
  const { setUrbit, receiveChallenge, receiveGame } = useStore()

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

  React.useEffect(() => { init() }, [])

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

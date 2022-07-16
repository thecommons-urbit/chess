import React from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Urbit from '@urbit/http-api'
import useChessStore from '../ts/state/chessStore'
import { GameInfo, ChallengeUpdate } from '../ts/types/urbitChess'
import { Chessboard } from './Chessboard'
import { Menu } from './Menu'

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
      event: (data: ChallengeUpdate) => receiveChallenge(data),
      quit: () => {}
    })

    await urbit.subscribe({
      app: 'chess',
      path: '/active-games',
      err: () => {},
      event: (data: GameInfo) => receiveGame(data),
      quit: () => {}
    })
  }

  // One time initialization hooks
  React.useEffect(
    () => { init() },
    [])

  //   React.useEffect(
  //     () => {
  //       const storedFen = window.localStorage.getItem('practiceFen')
  //       if (storedFen) {
  //         console.log('GETTING STORED FEN')
  //         updateFen(storedFen)
  //       }
  //     },
  //     [])

  // Load practice board placement from storage
  //   React.useEffect(
  //     () => {
  //       window.localStorage.setItem('practiceFen', fen)
  //     },
  //     [fen])

  return (
    <div className='app-container'>
      <Chessboard />
      <Menu />
    </div>
  )
}

export default App

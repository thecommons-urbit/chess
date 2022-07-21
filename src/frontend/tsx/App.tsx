import React from 'react'
import { Beforeunload } from 'react-beforeunload'
import Urbit from '@urbit/http-api'
import useChessStore from '../ts/state/chessStore'
import { GameInfo, ChallengeUpdate } from '../ts/types/urbitChess'
import { Chessboard } from './Chessboard'
import { Menu } from './Menu'

export function App () {
  const { urbit, setUrbit, receiveChallenge, receiveGame } = useChessStore()

  //
  // Helper functions
  //

  const init = async () => {
    const newUrbit = new Urbit('', '')
    newUrbit.ship = window.ship
    setUrbit(newUrbit)

    await newUrbit.subscribe({
      app: 'chess',
      path: '/challenges',
      err: () => {},
      event: (data: ChallengeUpdate) => receiveChallenge(data),
      quit: () => {}
    })
    await newUrbit.subscribe({
      app: 'chess',
      path: '/active-games',
      err: () => {},
      event: (data: GameInfo) => receiveGame(data),
      quit: () => {}
    })
  }

  const teardown = () => {
    urbit.delete()
  }

  //
  // React hooks
  //

  React.useEffect(
    () => { init() },
    [])

  //
  // Render app components
  //

  return (
    <Beforeunload onBeforeunload={teardown}>
      <div className='app-container'>
        <Chessboard />
        <Menu />
      </div>
    </Beforeunload>
  )
}

export default App

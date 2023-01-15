import React from 'react'
import { Beforeunload } from 'react-beforeunload'
import Urbit from '@urbit/http-api'
import useChessStore from '../ts/state/chessStore'
import { GameInfo, ChallengeUpdate } from '../ts/types/urbitChess'
import { findFriends } from '../ts/helpers/urbitChess'
import { Chessboard } from './Chessboard'
import { Menu } from './Menu'
import { GamePanel } from './GamePanel'
import { PracticePanel } from './PracticePanel'

export function App () {
  const { urbit, setUrbit, receiveChallengeUpdate, receiveGame, displayGame, setFriends } = useChessStore()

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
      event: (data: ChallengeUpdate) => receiveChallengeUpdate(data),
      quit: () => {}
    })
    await newUrbit.subscribe({
      app: 'chess',
      path: '/active-games',
      err: () => {},
      event: (data: GameInfo) => receiveGame(data),
      quit: () => {}
    })

    setFriends(await findFriends('chess', '/friends'))
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
        {
          (displayGame == null)
            ? <PracticePanel />
            : <GamePanel />
        }
        <Chessboard />
        <Menu />
      </div>
    </Beforeunload>
  )
}

export default App

import * as React from 'react'
import useStore from '../ts/chessStore'
import { Challenges } from './challenges'
import { Games } from './games'

export function Menu () {
  const {
    receivedChallenges,
    activeGames
  } = useStore()

  return (
    <div className='menu-container'>
      <Games activeGames={activeGames}/>
      <Challenges receivedChallenges={receivedChallenges}/>
    </div>
  )
}

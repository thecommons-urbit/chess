import * as React from 'react'
import useStore from '../chessStore'
import { Challenges } from '../ts/challenges'
import { Games } from '../ts/games'

export function Menu() {

  const {
    receivedChallenges,
    activeGames
  } = useStore();

  return(
    <div className='menu-container'>
      <Games activeGames={activeGames}/>
      <Challenges receivedChallenges={receivedChallenges}/>
    </div>
  )
}

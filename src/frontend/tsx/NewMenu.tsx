import * as React from 'react'
import { NewChallenges } from './NewChallenges'
import { NewGames } from './NewGames'

export function NewMenu () {
  return (
    <div className='new-menu-container'>
      <NewGames />
      <NewChallenges />
    </div>
  )
}

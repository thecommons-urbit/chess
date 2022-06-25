import React from 'react'
import { useParams } from 'react-router-dom'
import { NewGameBoard } from './NewGameBoard'
import { NewMenu } from './NewMenu'
import { NewPracticeBoard } from './NewPracticeBoard'

export function NewMain () {
  const { gameId } = useParams<{ gameId: string | null }>()

  if (gameId) {
    return (
      <div className='app-container'>
        <NewGameBoard gameId={gameId}/>
        <NewMenu />
      </div>
    )
  }

  return (
    <div className='app-container'>
      <NewPracticeBoard />
      <NewMenu />
    </div>
  )
}

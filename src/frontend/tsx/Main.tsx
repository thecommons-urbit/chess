import React from 'react'
import { useParams } from 'react-router-dom'
import { GameBoard } from './GameBoard'
import { Menu } from './Menu'
import { PracticeBoard } from './PracticeBoard'

export function Main () {
  const { gameId } = useParams<{ gameId: string | null }>()

  if (gameId) {
    return (
      <div className='app-container'>
        <GameBoard gameId={gameId}/>
        <Menu />
      </div>
    )
  }

  return (
    <div className='app-container'>
      <PracticeBoard />
      <Menu />
    </div>
  )
}

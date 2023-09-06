import React, { useState } from 'react'
import { Chess, ChessInstance } from 'chess.js'
import useChessStore from '../ts/state/chessStore'
import { CHESS } from '../ts/constants/chess'
import { Side, GameID, SAN, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'

export function PracticePanel () {
  const { displayGame, setPracticeBoard } = useChessStore()
  const hasGame: boolean = (displayGame !== null)
  const practiceHasMoved = (localStorage.getItem('practiceBoard') !== CHESS.defaultFEN)
  return (
    <div className='game-panel-container col'>
      <div className="game-panel col">
        <button
          className='option'
          disabled={!practiceHasMoved}
          onClick={() => setPracticeBoard(null)}>
          Reset Practice Board
        </button>
      </div>
    </div>
  )
}

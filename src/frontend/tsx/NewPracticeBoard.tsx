import * as React from 'react'
import Chessboard from 'chessboardjsx'
import useStore from '../ts/chessStore'

export function NewPracticeBoard () {
  const { practicePos, updatePracticePos } = useStore()

  return (
    <div className='board-container'>
      <div className='board-proper'>
        <Chessboard
          id = 'practice'
          position = {practicePos}
          onDrop = {() => { updatePracticePos(this.game.fen) }}
          calcWidth = { ({ screenWidth, screenHeight }) =>
            Math.min(
              Math.floor(screenWidth * (4/5)),
              Math.floor(screenHeight * (4/5))
            )}
        />
      </div>
    </div>
  )
}

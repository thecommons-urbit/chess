import * as React from 'react'
import updatePracticeBoardStore from '../ts/stores/practiceBoardStore'
import Chessground from './Chessground'

import 'chessground/assets/chessground.base.css'
import 'chessground/assets/chessground.brown.css'
import 'chessground/assets/chessground.cburnett.css'

export function PracticeBoard () {
  const { fen, api, baseConfig, setApi } = updatePracticeBoardStore()
  const config = {
    fen: fen,
    ...baseConfig
  }

  return (
    <div className='board-container'>
      <Chessground
        api={api}
        setApi={setApi}
        contained={true}
        config={config}
      />
    </div>
  )
}

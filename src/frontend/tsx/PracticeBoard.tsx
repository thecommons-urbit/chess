import React, { useState } from 'react'
import { Chess, ChessInstance, Square, SQUARES } from 'chess.js'
import { Config as CgConfig } from 'chessground/config'
import * as cg from 'chessground/types'
import usePracticeBoardStore from '../ts/stores/practiceBoardStore'
import Chessground from './Chessground'

import 'chessground/assets/chessground.base.css'
import 'chessground/assets/chessground.brown.css'
import 'chessground/assets/chessground.cburnett.css'

function getDests (chess: ChessInstance) {
  const dests = new Map()

  SQUARES.forEach(function (s: Square) {
    const ms = chess.moves({ square: s, verbose: true })
    if (ms.length) {
      dests.set(s, ms.map(m => m.to))
    }
  })

  return dests
}

export function PracticeBoard () {
  const [dirtyState, setDirtyState] = useState(0)
  const { api, fen, updateFen } = usePracticeBoardStore()

  const chess = new Chess(fen)
  const colorPlaying = (chess.turn() === 'w') ? 'white' as const : 'black' as const
  const config: CgConfig = {
    fen: fen,
    turnColor: colorPlaying,
    check: chess.in_check(),
    viewOnly: chess.game_over(),
    movable: {
      dests: getDests(chess),
      color: colorPlaying,
      events: {
        after: (orig: cg.Key, dest: cg.Key, metadata: cg.MoveMetadata) => {
          const attemptMove = chess.move({ from: orig as Square, to: dest as Square })

          if (attemptMove !== null) {
            const newFen = chess.fen()

            // Workaround to keep animations for en passant
            if (attemptMove.flags === 'e') {
              const tempChess = new Chess(fen)
              const square = dest.charAt(0) + orig.charAt(1)

              tempChess.remove(square as Square)
              const workaroundConfig = { fen: tempChess.fen() }

              api?.set(workaroundConfig)
            }

            updateFen(newFen)
            setDirtyState(0)
          } else {
            setDirtyState(dirtyState + 1)
          }
        }
      }
    }
  }

  api?.set(config)

  return (
    <div className='game-container'>
      <div className='title-container'>
        <h1 className='board-title'>{`${window.ship}'s practice board`}</h1>
      </div>
      <div className='board-container'>
        <Chessground />
      </div>
    </div>
  )
}

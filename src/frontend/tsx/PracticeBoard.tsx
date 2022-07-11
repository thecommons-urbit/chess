import React, { useEffect, useRef, useState } from 'react'
import { Chess, ChessInstance, Square, FLAGS, SQUARES, WHITE, PAWN, KNIGHT, BISHOP, ROOK, QUEEN } from 'chess.js'
import { Chessground as CgApi } from 'chessground'
import { Config as CgConfig } from 'chessground/config'
import * as cg from 'chessground/types'
import usePracticeBoardStore from '../ts/stores/practiceBoardStore'

//
// Import Chessground style sheets
//

import 'chessground/assets/chessground.base.css'
import 'chessground/assets/chessground.brown.css'
import 'chessground/assets/chessground.cburnett.css'

//
// Declare custom HTML elements used by Chessground
//

declare global {
  namespace JSX {
    interface IntrinsicElements {
      'cg-container': any;
      'cg-board': any;
      'piece': any;
      'square': any;
    }
  }
}

//
// Custom types
//

type Role = typeof QUEEN | typeof ROOK | typeof KNIGHT | typeof BISHOP

//
// Helper values
//

const promotionRoles: Map<cg.Role, Role> = new Map([
  ['queen', QUEEN],
  ['rook', ROOK],
  ['knight', KNIGHT],
  ['bishop', BISHOP]
])

//
// Helper functions
//

function getCgColor (color: string): cg.Color {
  return (color === WHITE) ? 'white' as const : 'black' as const
}

function getDests (chess: ChessInstance): Map<cg.Key, cg.Key[]> {
  const dests = new Map()

  SQUARES.forEach(function (s: Square) {
    const ms = chess.moves({ square: s, verbose: true })
    if (ms.length) {
      dests.set(s, ms.map(m => m.to))
    }
  })

  return dests
}

function isPromotion (orig: cg.Key, dest: cg.Key, chess: ChessInstance): boolean {
  const destRank = dest.charAt(1)

  if ((chess.get(orig as Square).type === PAWN) && ((destRank === '1') || (destRank === '8'))) {
    return true
  }

  return false
}

//
// Generate Chess board
//

export function PracticeBoard () {
  const boardRef = useRef(null)
  const [pendingUpdate, setPendingUpdate] = useState(true)
  const { api, chess, promotion, baseConfig, setApi, setChess, updatePromotion } = usePracticeBoardStore()

  //
  // TEMP
  //

  const zIndex = (promotion !== null) ? 3 : 1
  const pointerEvents = (promotion !== null) ? 'auto' : 'none'

  //
  // React hook helper functions
  //

  const initChess = () => {
    setChess(new Chess())
  }

  const configBoard = () => {
    const newApi = CgApi(boardRef.current, baseConfig)

    const promotionAttempt = (orig: cg.Key, dest: cg.Key) => {
      const newPromotion = {
        orig: orig,
        dest: dest,
        color: getCgColor(chess.turn()),
        orientation: 'white' as const
      }
      updatePromotion(newPromotion)
    }

    const moveAttempt = (orig: cg.Key, dest: cg.Key) => {
      const attemptMove = chess.move({ from: orig as Square, to: dest as Square })

      if (attemptMove !== null) {
        const newFen = chess.fen()

        // Workaround to keep animations for en passant
        if (attemptMove.flags === FLAGS.EP_CAPTURE) {
          const tempChess = new Chess(chess.fen())
          const square = dest.charAt(0) + orig.charAt(1)

          tempChess.remove(square as Square)
          const workaroundConfig = { fen: tempChess.fen() }
          const properConfig = { fen: newFen }

          newApi.set(workaroundConfig)
          newApi.set(properConfig)
        }

        setPendingUpdate(true)
      } else {
        console.log('REGULAR MOVE FAILED:')
        console.log(orig + ' -> ' + dest)
        console.log(chess.fen())
      }
    }

    const eventsConfig: CgConfig = {
      movable: {
        events: {
          after: (orig: cg.Key, dest: cg.Key, metadata: cg.MoveMetadata) => {
            if (isPromotion(orig, dest, chess)) {
              promotionAttempt(orig, dest)
            } else {
              moveAttempt(orig, dest)
            }
          }
        }
      }
    }

    newApi.set(eventsConfig)
    setApi(newApi)
  }

  const updateBoard = () => {
    const stateConfig: CgConfig = {
      fen: chess.fen(),
      turnColor: getCgColor(chess.turn()),
      check: chess.in_check(),
      viewOnly: chess.game_over(),
      movable: {
        dests: getDests(chess),
        color: getCgColor(chess.turn())
      }
    }
    api.set(stateConfig)

    setPendingUpdate(false)
  }

  //
  //
  //

  const promotionTiles = () => {
    const { orig, dest, color, orientation } = promotion

    const topBase = (orientation !== color) ? 7 : 0
    const topStep = (orientation !== color) ? -1 : 1
    const leftBase = (orientation === 'white')
      ? (dest.charCodeAt(0) - 97)
      : (7 - (dest.charCodeAt(0) - 97))

    return Array.from(promotionRoles).map(([role, promotionRole], i) => {
      const top = (topBase + (i * topStep)) * 12.5
      const left = leftBase * 12.5

      const recordRole = () => {
        const attemptMove = chess.move({
          from: orig as Square,
          to: dest as Square,
          promotion: promotionRole
        })

        if (attemptMove === null) {
          console.log('PROMOTION FAILED: ' + role)
          console.log(chess.fen())
        }

        setPendingUpdate(true)
        updatePromotion(null)
      }

      return (
        <square key={i} style={{ top: `${top}%`, left: `${left}%` }} onClick={recordRole}>
          <piece className={`${color} ${role}`} />
        </square>
      )
    })
  }

  const cancelPromotion = () => {
    setPendingUpdate(true)
    updatePromotion(null)
  }

  //
  // React hooks
  //

  useEffect(
    () => { initChess() },
    [])

  useEffect(
    () => {
      if ((chess !== null) && (boardRef !== null) && (boardRef.current !== null)) {
        configBoard()
      }
    },
    [chess, boardRef, baseConfig])

  useEffect(
    () => {
      if ((chess !== null) && (api !== null) && pendingUpdate) {
        updateBoard()
      }
    },
    [api, pendingUpdate])

  //
  // HTML Elements
  //

  return (
    <div className='game-container'>
      <div className='title-container'>
        <h1 className='board-title'>{`${window.ship}'s practice board`}</h1>
      </div>
      <div className='board-container'>
        <div ref={boardRef} className='chessboard cg-wrap' />
        <div
          className='chess-promotion cg-wrap'
          style={{ zIndex: `${zIndex}`, pointerEvents: `${pointerEvents}` }}
          onClick={cancelPromotion}>
          {(promotion !== null) ? promotionTiles() : <div/>}
        </div>
      </div>
    </div>
  )
}

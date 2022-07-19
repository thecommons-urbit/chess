import React, { useEffect, useRef, useState } from 'react'
import { Chess, ChessInstance, Square, FLAGS, WHITE } from 'chess.js'
import { Chessground } from 'chessground'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import * as cg from 'chessground/types'
import { CHESS } from '../ts/constants/chess'
import { CHESSGROUND } from '../ts/constants/chessground'
import { URBIT_CHESS } from '../ts/constants/urbitChess'
import { getChessDests, isChessPromotion } from '../ts/helpers/chess'
import { getCgColor } from '../ts/helpers/chessground'
import { pokeMove, move, castle, resign, offerDraw, acceptDraw, declineDraw } from '../ts/helpers/urbitChess'
import useChessStore from '../ts/state/chessStore'
import { PromotionMove } from '../ts/types/chessground'
import { Side, CastleSide, PromotionRole, Rank, File, GameID, ActiveGameInfo } from '../ts/types/urbitChess'

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
// Main
//

export function Chessboard () {
  const boardRef = useRef(null)
  const [api, setApi] = useState<CgApi>(null)
  const [chess, setChess] = useState<ChessInstance>(new Chess())
  const [promotionMove, setPromotionMove] = useState<PromotionMove | null>(null)
  const [renderWorkaround, forceRenderWorkaround] = useState<number>(Date.now())
  const { urbit, displayGame, activeGames, declinedDraw, offeredDraw, setDisplayGame } = useChessStore()

  //
  // Non-state constants
  //

  const orientation: Side = (displayGame !== null)
    ? (urbit.ship === displayGame.info.white.substring(1))
      ? Side.White
      : Side.Black
    : Side.White
  const sideToMove: Side = (displayGame !== null)
    ? (displayGame.position.split(' ')[1] === WHITE)
      ? Side.White
      : Side.Black
    : getCgColor(chess.turn()) as Side
  const boardTitle = (displayGame !== null)
    ? (orientation === Side.White)
      ? `${CHESS.pieceWhiteKnight} ${displayGame.info.white} vs. ${CHESS.pieceBlackKnight} ${displayGame.info.black}`
      : `${CHESS.pieceBlackKnight} ${displayGame.info.black} vs. ${CHESS.pieceWhiteKnight} ${displayGame.info.white}`
    : `~${window.ship}'s practice board`

  //
  // React hook helper functions
  //

  const initBoard = () => {
    setApi(Chessground(boardRef.current, CHESSGROUND.baseConfig))
  }

  const updateChess = () => {
    if (displayGame !== null) {
      chess.load(displayGame.position)
    } else {
      chess.load(CHESS.defaultFEN)
    }

    forceRenderWorkaround(Date.now())
  }

  const configBoard = () => {
    const attemptPromotion = (orig: cg.Key, dest: cg.Key) => {
      const promotionMove = {
        orig: orig,
        dest: dest
      }
      setPromotionMove(promotionMove)
    }

    const attemptMove = (orig: cg.Key, dest: cg.Key) => {
      const moveAttempt = chess.move({ from: orig as Square, to: dest as Square })

      const onError = () => {
        console.log('REGULAR MOVE FAILED:')
        console.log(orig + ' -> ' + dest)
        console.log(chess.fen())
      }

      const attemptUrbitMove = async (flag: string) => {
        if (flag === FLAGS.KSIDE_CASTLE) {
          await pokeMove(urbit, castle(displayGame.info.gameID, CastleSide.King), onError)
        } else if (flag === FLAGS.QSIDE_CASTLE) {
          await pokeMove(urbit, castle(displayGame.info.gameID, CastleSide.Queen), onError)
        } else {
          await pokeMove(
            urbit,
            move(
              displayGame.info.gameID,
              orig.charAt(1) as Rank,
              orig.charAt(0) as File,
              dest.charAt(1) as Rank,
              dest.charAt(0) as File,
              PromotionRole.None),
            onError)
        }
      }

      if (moveAttempt !== null) {
        if (displayGame !== null) {
          attemptUrbitMove(moveAttempt.flags)
        }
      } else {
        console.log('LOCAL FAILURE')
        onError()
      }
    }

    const config: CgConfig = {
      lastMove: null,
      orientation: orientation,
      movable: {
        color: (displayGame !== null) ? orientation : 'both' as const,
        events: {
          after: (orig: cg.Key, dest: cg.Key, metadata: cg.MoveMetadata) => {
            if (isChessPromotion(orig as Square, dest as Square, chess)) {
              attemptPromotion(orig, dest)
            } else {
              attemptMove(orig, dest)
            }

            forceRenderWorkaround(Date.now())
          }
        }
      }
    }
    api?.set(config)
  }

  const updateBoard = () => {
    const stateConfig: CgConfig = {
      fen: chess.fen(),
      turnColor: sideToMove as cg.Color,
      check: chess.in_check(),
      movable: {
        dests: getChessDests(chess) as cg.Dests
      }
    }
    api?.set(stateConfig)
  }

  //
  // React hooks
  //

  useEffect(
    () => {
      initBoard()
    },
    [boardRef])

  useEffect(
    () => {
      configBoard()
      updateBoard()
    },
    [api])

  useEffect(
    () => {
      updateChess()
      configBoard()
      updateBoard()
    },
    [displayGame])

  useEffect(
    () => {
      updateBoard()
    },
    [promotionMove, renderWorkaround])

  //
  // HTML element helper functions
  //

  const cancelPromotion = () => {
    setPromotionMove(null)
  }

  const resignOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeMove(urbit, resign(gameID, orientation))
  }

  const offerDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeMove(urbit, offerDraw(gameID), null, () => { offeredDraw(gameID) })
  }

  const acceptDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeMove(urbit, acceptDraw(gameID))
  }

  const declineDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeMove(urbit, declineDraw(gameID), null, () => { declinedDraw(gameID) })
  }

  //
  // HTML element generation functions
  //

  const promotionTiles = () => {
    const { orig, dest } = promotionMove

    const topBase = (orientation !== sideToMove) ? 7 : 0
    const topStep = (orientation !== sideToMove) ? -1 : 1
    const leftBase = (orientation === Side.White)
      ? (dest.charCodeAt(0) - 97)
      : (7 - (dest.charCodeAt(0) - 97))

    return CHESS.promotionRoles.map((piece, i) => {
      const top = (topBase + (i * topStep)) * 12.5
      const left = leftBase * 12.5

      const recordRole = async () => {
        const onError = () => {
          console.log('PROMOTION FAILED: ' + piece.cgRole)
          console.log(chess.fen())
        }

        const attemptMove = chess.move({
          from: orig as Square,
          to: dest as Square,
          promotion: piece.chessRole
        })

        const attemptUrbitMove = async () => {
          await pokeMove(
            urbit,
            move(
              displayGame.info.gameID,
              orig.charAt(1) as Rank,
              orig.charAt(0) as File,
              dest.charAt(1) as Rank,
              dest.charAt(0) as File,
              piece.urbitRole),
            onError)
        }

        if (attemptMove !== null) {
          if (displayGame !== null) {
            attemptUrbitMove()
          }
        } else {
          console.log('LOCAL FAILURE')
          onError()
        }

        setPromotionMove(null)
      }

      return (
        <square key={i} style={{ top: `${top}%`, left: `${left}%` }} onClick={recordRole}>
          <piece className={`${sideToMove} ${piece.cgRole}`} />
        </square>
      )
    })
  }

  //
  // Render HTML
  //

  const renderPromotionInterface = () => {
    return (
      <div
        className='chess-promotion cg-wrap'
        style={{ zIndex: '3', pointerEvents: 'auto' }}
        onClick={cancelPromotion}>
        {promotionTiles()}
      </div>
    )
  }

  const renderBoardControls = () => {
    return (
      <div className='board-controls'>
        <div className='board-draw-offer' hidden={!displayGame.gotDrawOffer}>
          <p>Opponent offered draw</p>
          <br/>
          <button onClick={acceptDrawOnClick}>Accept</button>
          <button onClick={declineDrawOnClick}>Decline</button>
        </div>
        <div className='board-buttons'>
          <div>
            <button disabled={displayGame.sentDrawOffer} onClick={offerDrawOnClick}>Offer Draw</button>
            <p hidden={!displayGame.sentDrawOffer}>Offered draw to opponent</p>
          </div>
          <div>
            <button onClick={resignOnClick}>Resign</button>
          </div>
          <div>
            <br/>
          </div>
          <div>
            <button onClick={() => setDisplayGame(null)}>Home</button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className='game-container'>
      <div className='title-container'>
        <p className='title-text' style={{ fontSize: URBIT_CHESS.lengthToFontSize.get(boardTitle.length) }}>
          {`${boardTitle}`}
        </p>
      </div>
      <div className='board-container'>
        <div ref={boardRef} className='chessboard cg-wrap' />
        { (promotionMove !== null) ? renderPromotionInterface() : <div/> }
      </div>
      <div className='turn-container'>
        <p className='turn-text'>{`${sideToMove} to move...`}</p>
      </div>
      { (displayGame !== null) ? renderBoardControls() : <div/> }
    </div>
  )
}
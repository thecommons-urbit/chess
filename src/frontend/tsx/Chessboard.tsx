import React, { useEffect, useRef, useState } from 'react'
import { Chess, ChessInstance, Square, FLAGS, WHITE } from 'chess.js'
import { Chessground } from 'chessground'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import * as cg from 'chessground/types'
import { CHESS } from '../ts/constants/chess'
import { CHESSGROUND } from '../ts/constants/chessground'
import { getChessDests, isChessPromotion } from '../ts/helpers/chess'
import { getCgColor } from '../ts/helpers/chessground'
import { pokeAction, movePoke, castlePoke, declineDrawPoke, claimSpecialDrawPoke, declineUndoPoke } from '../ts/helpers/urbitChess'
import useChessStore from '../ts/state/chessStore'
import usePreferenceStore from '../ts/state/preferenceStore'
import { PromotionMove } from '../ts/types/chessground'
import { Side, CastleSide, PromotionRole, Result, Rank, File, GameID, GameInfo, ActiveGameInfo, ArchivedGameInfo } from '../ts/types/urbitChess'

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
  const { urbit, displayGame, setDisplayGame, practiceBoard, setPracticeBoard, displayIndex } = useChessStore()
  const { pieceTheme, boardTheme } = usePreferenceStore()

  //
  // Non-state constants
  //

  const orientation: Side = (displayGame !== null)
    ? (urbit.ship === displayGame.white.substring(1))
      ? Side.White
      : Side.Black
    : Side.White
  const sideToMove: Side = (displayGame !== null)
    ? ((displayGame.moves.length % 2) === 0)
      ? Side.White
      : Side.Black
    : getCgColor(chess.turn()) as Side
  const isViewOnly = displayGame !== null &&
    (displayGame.archived ||
      ((displayGame.moves !== null) &&
        (displayGame.moves.length > 0) &&
        ((displayGame.moves.length - 1) > displayIndex)))
  const toShowDests = !isViewOnly

  //
  // React hook helper functions
  //

  const initBoard = () => {
    setApi(Chessground(boardRef.current, CHESSGROUND.baseConfig))
  }

  const initPracticeBoard = () => {
    const storedBoard = localStorage.getItem('practiceBoard')
    if (storedBoard !== null) {
      setPracticeBoard(storedBoard)
    }
  }

  const updateChess = () => {
    const practiceBoard = localStorage.getItem('practiceBoard')

    if (displayGame !== null && !displayGame.archived) {
      chess.load((displayGame as ActiveGameInfo).position)
    } else if (practiceBoard !== null) {
      chess.load(practiceBoard)
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
      const fenBeforeMove = chess.fen()
      const moveAttempt = chess.move({ from: orig as Square, to: dest as Square })

      const onError = () => {
        console.log('REGULAR MOVE FAILED:')
        console.log(orig + ' -> ' + dest)
        console.log(fenBeforeMove)
      }

      const attemptUrbitMove = async (flag: string) => {
        const gameID: GameID = displayGame.gameID

        if (flag === FLAGS.KSIDE_CASTLE) {
          await pokeAction(urbit, castlePoke(gameID, CastleSide.King), onError)
        } else if (flag === FLAGS.QSIDE_CASTLE) {
          await pokeAction(urbit, castlePoke(gameID, CastleSide.Queen), onError)
        } else {
          await pokeAction(
            urbit,
            movePoke(
              gameID,
              orig.charAt(1) as Rank,
              orig.charAt(0) as File,
              dest.charAt(1) as Rank,
              dest.charAt(0) as File,
              PromotionRole.None),
            onError)
        }

        //  XX: should moving decline draw offer in backend instead?
        if ((displayGame as ActiveGameInfo).gotDrawOffer) {
          await pokeAction(urbit, declineDrawPoke(gameID))
        }
        //  XX: should moving decline undo request in backend instead?
        if ((displayGame as ActiveGameInfo).gotUndoRequest) {
          await pokeAction(urbit, declineUndoPoke(gameID))
        }
      }

      if (moveAttempt !== null) {
        if (displayGame !== null) {
          attemptUrbitMove(moveAttempt.flags)
        }

        // Workaround to keep animations for en passant
        if (moveAttempt.flags === FLAGS.EP_CAPTURE) {
          const prevState = {
            fen: fenBeforeMove
          }
          const currState = {
            fen: chess.fen()
          }

          api.set(prevState)
          api.set(currState)
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

            if (displayGame == null) {
              forceRenderWorkaround(Date.now())
            }
          }
        }
      }
    }
    api?.set(config)
  }

  const updateBoard = () => {
    const stateConfig: CgConfig = {
      fen: displayGame == null
        ? chess.fen()
        : ((displayGame.moves == null) || (displayGame.moves.length === 0))
          ? CHESS.defaultFEN
          : displayGame.moves[displayIndex].fen,
      lastMove: (displayGame == null || displayGame.moves == null || (displayGame.moves.length === 0))
        ? null
        : [
          displayGame.moves[displayIndex].from,
          displayGame.moves[displayIndex].to
        ],
      viewOnly: isViewOnly,
      turnColor: sideToMove as cg.Color,
      check: chess.in_check(),
      selected: null,
      movable: {
        dests: getChessDests(chess) as cg.Dests,
        showDests: toShowDests
      }
    }
    // XX move these console logs to 'dev' branch once that exists
    console.log('updateBoard fen: ' + stateConfig.fen)
    console.log('updateBoard displayIndex: ' + displayIndex)
    api?.set(stateConfig)
  }

  const savePracticeBoard = () => {
    if (displayGame === null) {
      localStorage.setItem('practiceBoard', chess.fen())
      setPracticeBoard(chess.fen())
    }
  }

  const resetPracticeBoard = () => {
    if (practiceBoard === null) {
      localStorage.removeItem('practiceBoard')
      chess.load(CHESS.defaultFEN)
      if (displayGame == null) {
        forceRenderWorkaround(Date.now())
      }
      const config: CgConfig = {
        lastMove: null
      }
      api?.set(config)
    }
  }

  //
  // React hooks
  //

  useEffect(
    () => {
      initBoard()
      initPracticeBoard()
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
    [displayIndex])

  useEffect(
    () => {
      updateBoard()
      savePracticeBoard()
    },
    [promotionMove, renderWorkaround])

  useEffect(
    () => {
      resetPracticeBoard()
    },
    [practiceBoard])

  //
  // HTML element helper functions
  //

  const cancelPromotion = () => {
    setPromotionMove(null)
  }

  //
  // HTML element generation functions
  //

  const infoText = () => {
    if ((displayGame !== null) && displayGame.archived) {
      switch ((displayGame as ArchivedGameInfo).result) {
        case Result.WhiteVictory: {
          return 'winner: ' + displayGame.white
        }
        case Result.BlackVictory: {
          return 'winner: ' + displayGame.black
        }
        default: {
          return 'draw'
        }
      }
    } else {
      return (sideToMove + ' to move...')
    }
  }

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
          const gameID: GameID = displayGame.gameID

          await pokeAction(
            urbit,
            movePoke(
              gameID,
              orig.charAt(1) as Rank,
              orig.charAt(0) as File,
              dest.charAt(1) as Rank,
              dest.charAt(0) as File,
              piece.urbitRole),
            onError)

          //  XX: should moving decline draw offer in backend instead?
          if ((displayGame as ActiveGameInfo).gotDrawOffer) {
            await pokeAction(urbit, declineDrawPoke(gameID))
          }
          //  XX: should moving decline undo request in backend instead?
          if ((displayGame as ActiveGameInfo).gotUndoRequest) {
            await pokeAction(urbit, declineUndoPoke(gameID))
          }
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
        onClick={cancelPromotion}>
        {promotionTiles()}
      </div>
    )
  }

  return (
    <div className='game-container'>
      <div className={`board-container ${boardTheme} ${pieceTheme}`}>
        <div ref={boardRef} className='chessboard cg-wrap' />
        { ((displayGame !== null) && !(displayGame.archived) && (promotionMove !== null))
          ? renderPromotionInterface()
          : <div/>
        }
      </div>
      <div className='info-container'>
        <p className='info-text'>{infoText()}</p>
      </div>
    </div>
  )
}

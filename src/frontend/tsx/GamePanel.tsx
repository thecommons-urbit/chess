import React, { useState } from 'react'
import { Chess, ChessInstance } from 'chess.js'
import useChessStore from '../ts/state/chessStore'
import { pokeAction, resign, offerDraw, claimSpecialDraw, requestUndo } from '../ts/helpers/urbitChess'
import { CHESS } from '../ts/constants/chess'
import { Side, GameID, SAN, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'

export function GamePanel () {
  const { urbit, displayGame, setDisplayGame, offeredDraw, requestedUndo, practiceBoard, setPracticeBoard, displayIndex, setDisplayIndex } = useChessStore()
  const hasGame: boolean = (displayGame !== null)
  const practiceHasMoved = (localStorage.getItem('practiceBoard') !== CHESS.defaultFEN)
  const opponent = !hasGame ? '~sampel-palnet' : (urbit.ship === displayGame.info.white.substring(1))
    ? displayGame.info.black
    : displayGame.info.white

  const resignOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, resign(gameID))
  }

  const offerDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, offerDraw(gameID), null, () => { offeredDraw(gameID) })
  }

  const claimSpecialDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, claimSpecialDraw(gameID))
  }

  const requestUndoOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, requestUndo(gameID), null, () => { requestedUndo(gameID) })
  }

  const moveOpacity = (index: number) => {
    if (displayIndex == null || index <= displayIndex) {
      return 1.0
    } else {
      return 0.3
    }
  }

  const moveList = () => {
    let displayMoves = (displayGame.info.moves !== null) ? displayGame.info.moves : []
    let components = []
    for (let wIndex: number = 0; wIndex < displayMoves.length; wIndex += 2) {
      const move: number = (wIndex / 2) + 1
      const bIndex: number = wIndex + 1
      const wMove: SAN = displayMoves[wIndex].san

      if (bIndex >= displayMoves.length) {
        components.push(
          <li key={ move } className='move-item' style={{ opacity: moveOpacity(wIndex) }}>
            <span onClick={ () => setDisplayIndex(wIndex) }>
              { wMove }
            </span>
          </li>
        )
      } else {
        components.push(
          <li key={ move } className='move-item' style={{ opacity: moveOpacity(wIndex) }}>
            <span onClick={ () => setDisplayIndex(wIndex) }>
              { wMove }
            </span>
            { '\xa0'.repeat(6 - wMove.length) }
            {/* setting opacity to 1.0 offsets a cumulative reduction in opacity on each bIndex ply when displayIndex < this move's wIndex */}
            <span onClick={ () => setDisplayIndex(bIndex) } style={{ opacity: (moveOpacity(wIndex) === 1.0) ? moveOpacity(bIndex) : 1.0 }}>
              { displayMoves[wIndex + 1].san }
            </span>
          </li>
        )
      }
    }

    return components
  }

  const materialDifference = (fen: string) => {
    const board = fen.split(' ')[0]
    let whiteValue = 0
    let blackValue = 0

    for (let i = 0; i < board.length; i++) {
      const piece = board[i]
      if (piece === '/') {
        continue
      }
      const isWhite = piece === piece.toUpperCase()
      const value = CHESS.pieceValues[piece.toLowerCase()]
      if (isWhite) {
        whiteValue += value
      } else {
        blackValue += value
      }
    }

    return whiteValue - blackValue
  }

  return (
    <div className='game-panel-container col' style={{ display: ((displayGame !== null) ? 'flex' : ' none') }}>
      <div className="game-panel col">
        <div id="opp-captured" className={'captured row' + (hasGame ? '' : ' hidden')}>
          <p>
            { (displayGame.info.white !== window.ship)
            ? (materialDifference(displayGame.position) > 0) ? '+' + materialDifference(displayGame.position) : ''
            : (materialDifference(displayGame.position) < 0) ? '+' + Math.abs(materialDifference(displayGame.position)) : ''
            }
          </p>
        </div>
        <div id="opp-timer" className={'timer row' + (hasGame ? '' : ' hidden')}>
          <p>00:00</p>
        </div>
        <div id="opp-player" className={'player row' + (hasGame ? '' : ' hidden')}>
          <p>{opponent}</p>
        </div>
        <div className={'moves col' + (hasGame ? '' : ' hidden')}>
          <ol>
            { moveList() }
          </ol>
        </div>
        <div id="our-player" className={'player row' + (hasGame ? '' : ' hidden')}>
          <p>~{window.ship}</p>
        </div>
        <div id="our-timer" className={'timer row' + (hasGame ? '' : ' hidden')}>
          <p>00:00</p>
        </div>
        <div id="our-captured" className={'captured row' + (hasGame ? '' : ' hidden')}>
          <p>
          { (displayGame.info.white === window.ship)
            ? (materialDifference(displayGame.position) > 0) ? '+' + materialDifference(displayGame.position) : ''
            : (materialDifference(displayGame.position) < 0) ? '+' + Math.abs(materialDifference(displayGame.position))  : ''
            }
          </p>
        </div>
        {/* buttons */}
        {/* offer draw button */}
        <button
          className='option'
          disabled={!hasGame || displayGame.sentDrawOffer}
          onClick={offerDrawOnClick}>
          Offer Draw</button>
        {/* resign button */}
        <button
          className='option'
          disabled={!hasGame}
          onClick={resignOnClick}>
          Resign</button>
        {/* claim special draw */}
        {hasGame ? (
          <button
            className='option'
            disabled={!displayGame.drawClaimAvailable}
            onClick={claimSpecialDrawOnClick}>
            Claim Special Draw</button>
        ) : (null)
        }
        {/* request undo button */}
        {hasGame ? (
          <button
            className='option'
            disabled={displayGame.sentUndoRequest}
            onClick={requestUndoOnClick}>
            Request to Undo Move</button>
        ) : (null)
        }
        {/* (reset) practice board */}
        {hasGame ? (
          <button
            className='option'
            disabled={!hasGame}
            onClick={() => setDisplayGame(null)}>
            Practice Board</button>
        ) : (
          <button
            className='option'
            disabled={hasGame || !practiceHasMoved}
            onClick={() => setPracticeBoard(null)}>
            Reset Practice Board</button>
        )}
      </div>
    </div>
  )
}

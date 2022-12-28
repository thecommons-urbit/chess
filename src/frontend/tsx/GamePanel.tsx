import React from 'react'
import useChessStore from '../ts/state/chessStore'
import { pokeAction, resign, offerDraw, claimSpecialDraw } from '../ts/helpers/urbitChess'
import { Side, GameID, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'
import { CHESS } from '../ts/constants/chess'

export function GamePanel () {
  const { urbit, displayGame, setDisplayGame, offeredDraw, practiceBoard, setPracticeBoard } = useChessStore()
  const hasGame: boolean = (displayGame !== null)
  const practiceHasMoved = (localStorage.getItem('practiceBoard') !== CHESS.defaultFEN)

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

  return (
    <div className='game-panel-container col'>
      <div className="game-panel col">
        <div id="opp-timer" className={'timer row' + (hasGame ? '' : ' invisible')}>
          <p>00:00</p>
        </div>
        <div id="opp-player" className={'player row' + (hasGame ? '' : ' invisible')}>
          <p>~sampel-palnet</p>
        </div>
        <div className="moves col">
          <div className="moves-divider"></div>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
          <p> 00  ply ply</p>
        </div>
        <div id="our-player" className={'player row' + (hasGame ? '' : ' invisible')}>
          <p>~sampel-palnet</p>
        </div>
        <div id="our-timer" className={'timer row' + (hasGame ? '' : ' invisible')}>
          <p>00:00</p>
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

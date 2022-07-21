import React from 'react'
import { pokeAction, resign, offerDraw } from '../ts/helpers/urbitChess'
import { Side, GameID, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'
import useChessStore from '../ts/state/chessStore'

export function Games () {
  const { urbit, displayGame, activeGames, setDisplayGame, offeredDraw } = useChessStore()
  const hasGame: boolean = (displayGame !== null)

  const extractDate = (gameID: GameID) => {
    return (gameID.split('..')[0]).substring(1)
  }

  const resignOnClick = async () => {
    const gameID = displayGame.info.gameID
    const side = (urbit.ship === displayGame.info.white.substring(1)) ? Side.White : Side.Black
    await pokeAction(urbit, resign(gameID, side))
  }

  const offerDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, offerDraw(gameID), null, () => { offeredDraw(gameID) })
  }

  return (
    <div className='games-container col'>
      <div className='game-options col'>
        <button
          className='option'
          disabled={!hasGame || displayGame.sentDrawOffer}
          onClick={offerDrawOnClick}>
          offer draw</button>
        <button
          className='option'
          disabled={!hasGame}
          onClick={resignOnClick}>
          resign</button>
        <button
          className='option'
          disabled={!hasGame}
          onClick={() => setDisplayGame(null)}>
          practice board</button>
      </div>
      <ul className='game-list'>
        {
          Array.from(activeGames).map(([gameID, activeGame], key) => {
            const colorClass = (key % 2) ? 'odd' : 'even'
            const description = activeGame.info.event
            const mySide = (urbit.ship === activeGame.info.white.substring(1)) ? 'w' : 'b'
            const opponent = (urbit.ship === activeGame.info.white.substring(1))
              ? activeGame.info.black
              : activeGame.info.white

            return (
              <li
                key={key}
                className={`game active ${colorClass}`}
                title={gameID}
                onClick={() => setDisplayGame(activeGame)}>
                <div className='row'>
                  <img
                    src={`https://raw.githubusercontent.com/lichess-org/lila/5a9672eacb870d4d012ae09d95aa4a7fdd5c8dbf/public/piece/cburnett/${mySide}N.svg`}
                    height={60}
                    width={60}/>
                  <div className='col' style={{ width: 'calc(100% - 60px)' }}>
                    <p style={{ fontSize: '1.25rem' }}>{opponent}</p>
                    <p>{extractDate(gameID)}</p>
                    <p
                      title={description}
                      style={{ maxHeight: '2rem', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {description}
                    </p>
                  </div>
                </div>
              </li>
            )
          })
        }
      </ul>
    </div>
  )
}

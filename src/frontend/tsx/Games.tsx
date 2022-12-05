import React from 'react'
import { pokeAction, resign, offerDraw } from '../ts/helpers/urbitChess'
import { Side, GameID, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'
import useChessStore from '../ts/state/chessStore'

export function Games () {
  const { urbit, displayGame, activeGames, setDisplayGame } = useChessStore()
  const hasGame: boolean = (displayGame !== null)

  const extractDate = (gameID: GameID) => {
    return (gameID.split('..')[0]).substring(1)
  }

  return (
    <div className='games-container col'>
      <div id="active-archive-toggle">
        <p><span>Active</span> 𐫱 <span>Archive</span></p>
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
                    className='game-icon'
                    src={`https://raw.githubusercontent.com/lichess-org/lila/5a9672eacb870d4d012ae09d95aa4a7fdd5c8dbf/public/piece/cburnett/${mySide}N.svg`}
                  />
                  <div className='col game-card'>
                    <p className='game-opponent'>{opponent}</p>
                    <p className='game-date'>{extractDate(gameID)}</p>
                    <p
                      title={description}
                      className='game-desc'
                    >
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

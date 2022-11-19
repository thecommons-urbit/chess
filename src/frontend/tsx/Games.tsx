import React from 'react'
import { Side, GameID, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'
import useChessStore from '../ts/state/chessStore'
import usePreferenceStore from '../ts/state/preferenceStore'

export function Games () {
  const { urbit, displayGame, activeGames, setDisplayGame, setDisplayIndex } = useChessStore()
  const { pieceTheme } = usePreferenceStore()
  const hasGame: boolean = (displayGame !== null)

  const extractDate = (gameID: GameID) => {
    return (gameID.split('..')[0]).substring(1)
  }

  return (
    <div className='games-container col'>
      <div id="active-archive-toggle">
        <p><span>Active</span> 𐫱 <span>Archive</span></p>
      </div>
      <ul className={`game-list ${pieceTheme}`}>
        {
          Array.from(activeGames).map(([gameID, activeGame], key) => {
            const colorClass = (key % 2) ? 'odd' : 'even'
            const description = activeGame.info.event
            const mySide = (urbit.ship === activeGame.info.white.substring(1)) ? 'white' : 'black'
            const opponent = (urbit.ship === activeGame.info.white.substring(1))
              ? activeGame.info.black
              : activeGame.info.white

            return (
              <li
                key={key}
                className={`game active ${colorClass} ${status}`}
                title={gameID}
                onClick={() => { setDisplayGame(activeGame); setDisplayIndex(null) }}>
                <div className='row'>
                  <piece className={`game-icon ${mySide} knight`}/>
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

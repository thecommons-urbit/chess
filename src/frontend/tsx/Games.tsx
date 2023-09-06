import React, { useState } from 'react'
import { Side, GameID } from '../ts/types/urbitChess'
import useChessStore from '../ts/state/chessStore'
import usePreferenceStore from '../ts/state/preferenceStore'

export function Games () {
  const { urbit, displayGame, activeGames, setDisplayGame, archivedGames, displayArchivedGame } = useChessStore()
  const { pieceTheme } = usePreferenceStore()
  const hasGame: boolean = (displayGame !== null)
  const [showingActive, setShowingActive] = useState(true)

  const extractDate = (gameID: GameID) => {
    return (gameID.split('..')[0]).substring(1)
  }

  const openActive = () => {
    setShowingActive(true)
  }

  const openArchive = () => {
    setShowingActive(false)
  }

  return (
    <div className='games-container col'>
      <div id="active-archive-toggle">
        <p>
          <span onClick={openActive} style={{ opacity: (showingActive ? 1.0 : 0.5) }}>Active</span> 𐫱 <span onClick={openArchive} style={{ opacity: (showingActive ? 0.5 : 1.0) }}>Archive</span>
        </p>
      </div>
      {/* Active */}
      <ul id="active-games" className={`game-list ${pieceTheme}`} style={{ display: (showingActive ? 'flex' : 'none') }}>
        {
          Array.from(activeGames).map(([gameID, activeGame], key) => {
            const colorClass = (key % 2) ? 'odd' : 'even'
            const description = activeGame.event
            const mySide = (urbit.ship === activeGame.white.substring(1)) ? 'white' : 'black'
            const opponent = (urbit.ship === activeGame.white.substring(1))
              ? activeGame.black
              : activeGame.white

            return (
              <li
                key={key}
                className={`game active ${colorClass} ${status}`}
                title={gameID}
                onClick={() => { setDisplayGame(activeGame) }}>
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
      {/* Archive */}
      <ul id="archive-games" className={`game-list ${pieceTheme} ${status}`} style={{ display: (showingActive ? 'none' : 'flex') }}>
        {
          Array.from(archivedGames).map(([gameID, archivedGame], key) => {
            const colorClass = (key % 2) ? 'odd' : 'even'
            const description = archivedGame.event
            const mySide = (urbit.ship === archivedGame.white.substring(1)) ? 'white' : 'black'
            const opponent = (urbit.ship === archivedGame.white.substring(1))
              ? archivedGame.black
              : archivedGame.white

            return (
              <li
                key={key}
                className={`game active ${colorClass}`}
                title={gameID}
                onClick={() => { displayArchivedGame(gameID) }}>
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

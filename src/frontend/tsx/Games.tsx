import React, { useState } from 'react'
import { Side, GameID } from '../ts/types/urbitChess'
import { scryArchive } from '../ts/helpers/urbitChess'
import useChessStore from '../ts/state/chessStore'
import usePreferenceStore from '../ts/state/preferenceStore'

export function Games () {
  // data
  const { urbit, displayGame, activeGames, setDisplayGame, setDisplayIndex, localArchive, setLocalArchive, showingArchive, setShowingArchive } = useChessStore()
  const { pieceTheme } = usePreferenceStore()
  const hasGame: boolean = (displayGame !== null)

  const extractDate = (gameID: GameID) => {
    return (gameID.split('..')[0]).substring(1)
  }
  // interface
  const [showingActive, setShowingActive] = useState(true)

  const openActive = () => {
    setShowingActive(true)
  }

  const openArchive = async () => {
    setShowingActive(false)
    setLocalArchive(await scryArchive('chess', '/archive/all'))
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
                onClick={() => { setDisplayGame(activeGame); setDisplayIndex(null); setShowingArchive(false) }}>
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
          Array.from(localArchive).map(([gameID, archiveGame], key) => {
            const colorClass = (key % 2) ? 'odd' : 'even'
            const description = archiveGame.info.event
            const mySide = (urbit.ship === archiveGame.info.white.substring(1)) ? 'white' : 'black'
            const opponent = (urbit.ship === archiveGame.info.white.substring(1))
              ? archiveGame.info.black
              : archiveGame.info.white

            return (
              <li
                key={key}
                className={`game active ${colorClass}`}
                title={gameID}
                onClick={() => { setDisplayGame(archiveGame); setDisplayIndex(null); setShowingArchive(true) }}>
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

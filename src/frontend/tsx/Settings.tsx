import React from 'react'
import { pokeAction, changeSpecialDrawPreference } from '../ts/helpers/urbitChess'
import useChessStore from '../ts/state/chessStore'

export function Settings () {
  const { urbit, displayGame, activeGames } = useChessStore()
  const hasGame: boolean = (displayGame !== null)

  const handleCheckboxChange = async () => {
    const newAutoClaimPreference = !displayGame.autoClaimSpecialDraws
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, changeSpecialDrawPreference(gameID, newAutoClaimPreference))
  }

  return (
    <div className='settings-container'>
      <div id="visuals-settings" className="control-panel-container col">
        <h4 className="control-panel-header">Visuals</h4>
      </div>
      <div id="gameplay-settings" className="control-panel-container col">
        <h4 className="control-panel-header">Gameplay</h4>
        {hasGame ? (
          <label>
            <input
              type="checkbox"
              checked={displayGame.autoClaimSpecialDraws}
              onChange={handleCheckboxChange}
            />
            Auto-Claim Special Draws
          </label>
        ) : (null)
        }
      </div>
      <div id="data-settings" className="control-panel-container col">
        <h4 className="control-panel-header">Data</h4>
        <button>Export PGN</button>
      </div>
      <div id="settings-footer" className="control-panel-container col">
        <p><a href="">Credits</a> • <a href="https://github.com/ashelkovnykov/urbit-chess">GitHub</a></p>
      </div>
    </div>
  )
}

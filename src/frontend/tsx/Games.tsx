import * as React from 'react'
import { GameID, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'
import useChessStore from '../ts/state/chessStore'

export function Games () {
  const { activeGames, setDisplayGame } = useChessStore()

  const onClick = (activeGame: ActiveGameInfo) => {
    setDisplayGame(activeGame)
  }

  const wrapDAU = (gameID: GameID) => {
    var parts = gameID.split('..')

    return parts.join('..\u200b')
  }

  const extractRound = (chessGameInfo: GameInfo) => {
    return chessGameInfo.round === '' ? '' : `: Round ${chessGameInfo.round}`
  }

  return (
    <div className='games-container'>
      <h1>Active Games</h1>
      <div className='games-list'>
        <ul>
          {
            Array.from(activeGames).map(([gameID, activeGame]) => {
              return (
                <li
                  key={gameID}
                  className='game-active'
                  onClick={() => onClick(activeGame)}>
                  {`${wrapDAU(gameID)}`}<br/>
                  {`${activeGame.info.event}${extractRound(activeGame.info)}`}<br/>
                  {`${activeGame.info.white}(W) vs. ${activeGame.info.black}(B)`}<br/>
                </li>)
            })
          }
        </ul>
      </div>
    </div>)
}

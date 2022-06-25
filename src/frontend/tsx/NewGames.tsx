import * as React from 'react'
import useStore from '../ts/chessStore'
import { useNavigate } from 'react-router-dom'
import { ChessActiveGameInfo, ChessGameID, ChessGameInfo } from '../ts/types'

export function NewGames () {
  const { activeGames } = useStore()
  const navigate = useNavigate()

  const onClick = (gameID: ChessGameID) => {
    navigate(`/${gameID}`)
  }

  const wrapDAU = (gameID: ChessGameID) => {
    var parts = gameID.split('..')

    return parts.join('..\u200b')
  }

  const extractRound = (chessGameInfo: ChessGameInfo) => {
    return chessGameInfo.round === '' ? '' : `: Round ${chessGameInfo.round}`
  }

  return (
    <div className='new-games-container'>
      <h1>Active Games</h1>
      <div className='games-list'>
        <ul>
          {
            Array.from(activeGames).map(([gameID, activeGame]) => {
              return (
                <li
                  key={gameID}
                  className='game-active'
                  onClick={() => onClick(gameID)}>
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

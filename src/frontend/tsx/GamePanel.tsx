// XX: do we need to import React, or can we get rid of this line throughout the codebase?
//     it depends on the version
import React from 'react'
import Urbit from '@urbit/http-api'
import ChessState from '../ts/state/chessState'
import useChessStore from '../ts/state/chessStore'
import { GamePanelInfo } from '../ts/types/urbitChess'

// XX: should we return a new <GamePanel /> for every game?
// XX: if so, we might just pass { game }; if not, it needs more
export function GamePanel (game: GamePanelInfo) {
  // get player ship names
  const ourShip = window.ship
  const oppShip = (ourShip === game.info.white) ? game.info.white : game.info.black

  // const: listen for timer info for both players
  //        XX: need timer server

  // const: listen on <game-id>/moves wire for the list of moves
  //        push the new move to the relevant function
  const watchGameMoves = (gameID: GameID) => {
    await get().urbit.subscribe({
      app: 'chess',
      path: `/game/${data.gameID}/moves`,
      err: () => {},
      // XX: need to add a function here, updateGamePanel(data)?
      event: (move: MoveMoveAction) => {},
      quit: () => {}
    })
  }

  // const: frontend state for active games, move numbers, and moves in a JS array
  //        start with an array of the moves, from moves.chess-game
  //        that array is refreshed every time a new move is added to /game-id/moves
  //        when that array is refreshed, we iterate over it to create a map of key-value pairs
  //        that map is sent to the game panel, which displays it pretty much as shown in the frontend sketch

  // const: frontend state for archived games, move numbers, and moves in a JS array
  //        same as frontend for active games
  //

  // const: listen on a wire, maybe <game-id>/updates, for updates
  //        on which we want buttons to appear/disappear
  //        e.g. we can claim a 50-move draw

  // const: listen on frontend for events on which we want buttons
  //        to appear/disappear
  //        e.g. we're viewing a previous position, offer the undo/revert button

  // const: "transformation function" from active game to archived game
  //        on the frontend, this involves moving the game's card in the Control Panel
  //        from Active to Archive
  //        we also need to "boot" the player not to the practice board, but the last move
  //        in the archived game that was just created

  return (
    <div className='game-panel-container'>
      <div className='game-panel'>
        <div className='game-timer'>
          {/* XX: opponent's timer */}
          <p>00:00</p>
        </div>
        <div className='game-player'>
          {/* opponent ship */}
          <p>{`~${oppShip}`}</p>
        </div>
        <div className='game-moves'>
          {/* list of moves will be inserted here */}
          {/* XX: should be placeholder moves for now
                  don't need this to unblock other issues
                  just need to be able to view completed games */}
        </div>
        <div className='game-player'>
          <p>{`~${ourShip}`}</p>
        </div>
        <div className='game-timer'>
          {/* XX: our timer */}
          <p>00:00</p>
        </div>
      </div>
      <div className='game-buttons-list'>
        {/* any buttons relevant at the given moment */}
      </div>
    </div>
  )
}

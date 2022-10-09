import React from 'react'
// XX: i'm not sure if these imports are right
import useChessStore from '../ts/state/chessStore'
import { ChessUpdate, PositionUpdate, ResultUpdate, GameID, Rank, File, Side, CastleSide, PromotionRole, ActiveGameInfo } from '../ts/types/urbitChess'

export function GamePanel () {
  // get player ship names
  const ourShip = window.ship
  // XX: opponent ship
  //
  // function: listen for timer info for both players
  //           XX: need timer server
  //
  // function: - listen on <game-id>/moves wire for the list of moves
  //           - do any formatting necessary
  //
  // function: listen on a wire, maybe <game-id>/updates, for updates
  //           on which we want buttons to appear/disappear
  //           e.g. we can claim a 50-move draw
  //
  // function: listen on frontend for events on which we want buttons
  //           to appear/disappear
  //           e.g. we're viewing a previous position, offer the undo/revert button
  //
  return (
    <div className='game-panel-container'>
      <div className='game-panel'>
        <div className='game-timer'>
          {/* XX: opponent's timer */}
          <p>00:00</p>
        </div>
        <div className='game-player'>
          {/* opponent ship */}
        </div>
        <div className='game-moves'>
          {/* list of moves will be inserted here */}
          {/* XX: should be placeholder moves for now
                  don't need this to unblock other issues
                  just need to be able to view completed games */}
        </div>
        <div className='game-player'>
          <p>`~${ourShip}`</p>
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

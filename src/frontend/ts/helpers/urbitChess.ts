import Urbit from '@urbit/http-api'
import { Side, CastleSide, PromotionRole, Result, Action, MoveActionAction, GameID, Rank, File, ChessAction, OfferDrawAction, AcceptDrawAction, DeclineDrawAction, MoveAction, MoveMoveAction, CastleMoveAction, EndMoveAction } from '../types/urbitChess'

function emptyFunction (): void {}

export function pokeMove (urbit: Urbit, move: ChessAction, onError?: () => void, onSuccess?: () => void) {
  const pokeInput = {
    app: 'chess',
    mark: 'chess-action',
    json: move,
    onError: (typeof onError !== 'undefined') ? onError : emptyFunction,
    onSuccess: (typeof onSuccess !== 'undefined') ? onSuccess : emptyFunction
  }

  urbit.poke(pokeInput)
}

export function move (
  gameId: GameID,
  srcRank: Rank,
  srcFile: File,
  destRank: Rank,
  destFile: File,
  promotion: PromotionRole): MoveMoveAction {
  const move: MoveMoveAction = {
    'chess-action': Action.Move,
    'chess-move': MoveActionAction.Move,
    'game-id': gameId,
    'from-rank': srcRank,
    'from-file': srcFile,
    'to-rank': destRank,
    'to-file': destFile,
    'into': promotion
  }

  return move
}

export function castle (gameId: GameID, side: CastleSide): CastleMoveAction {
  const move = {
    'chess-action': Action.Move,
    'chess-move': MoveActionAction.Castle,
    'game-id': gameId,
    'castle-side': side
  }

  return (move as CastleMoveAction)
}

export function resign (gameId: GameID, side: Side): EndMoveAction {
  const move = {
    'chess-action': Action.Move,
    'chess-move': MoveActionAction.End,
    'game-id': gameId,
    'result': (side === Side.White) ? Result.BlackVictory : Result.WhiteVictory
  }

  return (move as EndMoveAction)
}

export function offerDraw (gameId: GameID): OfferDrawAction {
  const move = {
    'chess-action': Action.OfferDraw,
    'game-id': gameId
  }

  return (move as OfferDrawAction)
}

export function acceptDraw (gameId: GameID): AcceptDrawAction {
  const move = {
    'chess-action': Action.AcceptDraw,
    'game-id': gameId
  }

  return (move as AcceptDrawAction)
}

export function declineDraw (gameId: GameID): DeclineDrawAction {
  const move = {
    'chess-action': Action.DeclineDraw,
    'game-id': gameId
  }

  return (move as DeclineDrawAction)
}

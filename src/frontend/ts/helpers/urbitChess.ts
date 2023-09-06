import Urbit from '@urbit/http-api'
import { Side, CastleSide, PromotionRole, Action, MoveActionAction, Rank, File, Ship, GameID, Move, ChessAction, ChessChallengeAction, ChessSendChallengeAction, ChessDeclineChallengeAction, ChessAcceptChallengeAction, ChessGameAction, ResignAction, OfferDrawAction, RevokeDrawAction, DeclineDrawAction, AcceptDrawAction, ClaimSpecialDrawAction, RequestUndoAction, DeclineUndoAction, AcceptUndoAction, RevokeUndoAction, MoveAction, CastleAction, ChangeSpecialDrawPreferenceAction } from '../types/urbitChess'

//
// Eyre actions
//

// Helper function for null callbacks
function emptyFunction (): void {}

export function pokeAction (urbit: Urbit, action: ChessAction, onError?: () => void, onSuccess?: () => void) {
  const pokeInput = {
    app: 'chess',
    mark: 'chess-user-action',
    json: action,
    onError: (typeof onError !== 'undefined') ? onError : emptyFunction,
    onSuccess: (typeof onSuccess !== 'undefined') ? onSuccess : emptyFunction
  }

  urbit.poke(pokeInput)
}

export function scryAction (app: string, path: string) {
  const urbit = new Urbit('')
  return urbit.scry({ app: app, path: path })
}

//
// Poke helpers
//

//  Challenges

export function sendChallengePoke (who: Ship, side: Side, description: string) {
  const action: ChessSendChallengeAction = {
    'chess-user-action': Action.SendChallenge,
    'who': who,
    'challenger-side': side,
    'event': description
  }

  return action
}

function respondToChallenge<T> (action: Action, who: Ship) : ChessChallengeAction {
  const response = {
    'chess-user-action': action,
    'who': who
  }

  return response
}

export function acceptChallengePoke (who: Ship) {
  return respondToChallenge<ChessAcceptChallengeAction>(Action.AcceptChallenge, who)
}

export function declineChallengePoke (who: Ship) {
  return respondToChallenge<ChessDeclineChallengeAction>(Action.DeclineChallenge, who)
}

//  Games

function chessAction<T> (action: Action, gameId: GameID) : ChessGameAction {
  const chessAction = {
    'chess-user-action': action,
    'game-id': gameId
  }

  return chessAction
}

//    Resignations

export function resignPoke (gameId: GameID) {
  return chessAction<ResignAction>(Action.Resign, gameId)
}

//    Draws

export function offerDrawPoke (gameId: GameID) {
  return chessAction<OfferDrawAction>(Action.OfferDraw, gameId)
}

export function revokeDrawPoke (gameId: GameID) {
  return chessAction<RevokeDrawAction>(Action.RevokeDraw, gameId)
}

export function declineDrawPoke (gameId: GameID) {
  return chessAction<DeclineDrawAction>(Action.DeclineDraw, gameId)
}

export function acceptDrawPoke (gameId: GameID) {
  return chessAction<AcceptDrawAction>(Action.AcceptDraw, gameId)
}

export function claimSpecialDrawPoke (gameId: GameID) {
  return chessAction<ClaimSpecialDrawAction>(Action.ClaimSpecialDraw, gameId)
}

//    Undos

export function requestUndoPoke (gameId: GameID) {
  return chessAction<RequestUndoAction>(Action.RequestUndo, gameId)
}

export function revokeUndoPoke (gameId: GameID) {
  return chessAction<RevokeUndoAction>(Action.RevokeUndo, gameId)
}

export function declineUndoPoke (gameId: GameID) {
  return chessAction<DeclineUndoAction>(Action.DeclineUndo, gameId)
}

export function acceptUndoPoke (gameId: GameID) {
  return chessAction<AcceptUndoAction>(Action.AcceptUndo, gameId)
}

//    Moves

export function movePoke (
  gameId: GameID,
  srcRank: Rank,
  srcFile: File,
  destRank: Rank,
  destFile: File,
  promotion: PromotionRole): MoveAction {
  const move: MoveAction = {
    'chess-user-action': Action.MakeMove,
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

export function castlePoke (gameId: GameID, side: CastleSide): CastleAction {
  const move: CastleAction = {
    'chess-user-action': Action.MakeMove,
    'chess-move': MoveActionAction.Castle,
    'game-id': gameId,
    'castle-side': side
  }

  return move
}

//    Preferences

export function changeSpecialDrawPreferencePoke (
  gameId: GameID,
  setting: boolean): ChangeSpecialDrawPreferenceAction {
  const action: ChangeSpecialDrawPreferenceAction = {
    'chess-user-action': Action.ChangeSpecialDrawPreference,
    'game-id': gameId,
    'setting': setting
  }

  return action
}

//
// Scry helpers
//

export const scryFriends = async (app: string, path: string) => {
  const scryOutput: { friends: Array<Ship> } = JSON.parse(JSON.stringify(await scryAction(app, path), null, 2))

  return scryOutput.friends
}

export const scryMoves = async (app: string, path: string) => {
  const scryOutput: { moves: Array<Move> } = JSON.parse(JSON.stringify(await scryAction(app, path), null, 2))
  return scryOutput.moves
}

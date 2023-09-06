import { Key as CgKey } from 'chessground/types'

/**
 * Enumerations
 */

//
// Basic enums for frontend state & logic flow
//

export enum Side {
  White = 'white',
  Black = 'black',
  Random = 'random'
}

//
// Enums for constructing pokes to backend
//

export enum CastleSide {
  King = 'kingside',
  Queen = 'queenside'
}

export enum PromotionRole {
  Queen = 'queen',
  Rook = 'rook',
  Knight = 'knight',
  Bishop = 'bishop',
  None = ''
}

export enum Action {
  SendChallenge = 'send-challenge',
  AcceptChallenge = 'accept-challenge',
  DeclineChallenge = 'decline-challenge',
  Resign = 'resign',
  OfferDraw = 'offer-draw',
  RevokeDraw = 'revoke-draw',
  DeclineDraw = 'decline-draw',
  AcceptDraw = 'accept-draw',
  ClaimSpecialDraw = 'claim-special-draw',
  RequestUndo = 'request-undo',
  RevokeUndo = 'revoke-undo',
  DeclineUndo = 'decline-undo',
  AcceptUndo = 'accept-undo',
  MakeMove = 'make-move',
  ChangeSpecialDrawPreference = 'change-special-draw-preference'
}

// Yes, we know how retarded 'MoveActionAction.Move' looks
export enum MoveActionAction {
  Move = 'move',
  Castle = 'castle',
}

//
// Enums for receiving updates from backend
//

export enum Result {
  WhiteVictory = '1-0',
  BlackVictory = '0-1',
  Draw = '½–½'
}

export enum Update {
  ChallengeSent = 'challenge-sent',
  ChallengeReceived = 'challenge-received',
  ChallengeReplied = 'challenge-replied',
  ChallengeResolved = 'challenge-resolved',
  Position = 'position',
  Result = 'result',
  OfferedDraw = 'offered-draw',
  DrawOffered = 'draw-offered',
  RevokedDraw = 'revoked-draw',
  DrawRevoked = 'draw-revoked',
  DeclinedDraw = 'declined-draw',
  DrawDeclined = 'draw-declined',
  SpecialDrawPreference = 'special-draw-preference',
  RequestedUndo = 'requested-undo',
  UndoRequested = 'undo-requested',
  RevokedUndo = 'revoked-undo',
  UndoRevoked = 'undo-revoked',
  DeclinedUndo = 'declined-undo',
  UndoDeclined = 'undo-declined',
  AcceptedUndo = 'accepted-undo',
  UndoAccepted = 'undo-accepted'
}

/**
 * Types
 */

export type Rank = '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8'
export type File = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'

export type Ship = string

export type GameID = string

export type SAN = string

export type FENPosition = string

/**
 * Interfaces
 */

//
// Generic
//

export interface Move {
  from: CgKey
  to: CgKey
  san: SAN
  fen: FENPosition
}

export interface Challenge {
  who: Ship,
  challengerSide: Side,
  event: string
}

//
// Game Info
//

export interface GameInfo {
  gameID: GameID,
  event: string,
  white: Ship,
  black: Ship,
  archived: boolean,
  moves: Array<Move>
}

export interface ActiveGameInfo extends GameInfo {
  position: FENPosition,
  gotDrawOffer: boolean,
  sentDrawOffer: boolean,
  drawClaimAvailable: boolean,
  autoClaimSpecialDraws: boolean,
  gotUndoRequest: boolean,
  sentUndoRequest: boolean
}

export interface ArchivedGameInfo extends GameInfo {
  result: Result
}

//
// Updates
//

export interface ChessUpdate {
  chessUpdate: Update
}

export interface ChallengeUpdate extends ChessUpdate {
  chessUpdate: Update.ChallengeSent |
               Update.ChallengeReceived |
               Update.ChallengeResolved |
               Update.ChallengeReplied
  who: Ship
}

export interface ChallengeSentUpdate extends ChallengeUpdate {
  chessUpdate: Update.ChallengeSent
  challengerSide: Side
  event: string
}

export interface ChallengeReceivedUpdate extends ChallengeUpdate {
  chessUpdate: Update.ChallengeReceived
  challengerSide: Side
  event: string
}

export interface PositionUpdate extends ChessUpdate {
  chessUpdate: Update.Position
  gameID: GameID
  specialDrawAvailable: boolean
  move: Move | null
}

export interface ResultUpdate extends ChessUpdate {
  chessUpdate: Update.Result
  gameID: GameID
  result: Result
}

export interface DrawUpdate extends ChessUpdate {
  chessUpdate: Update.OfferedDraw |
               Update.DrawOffered |
               Update.DrawRevoked |
               Update.RevokedDraw |
               Update.DeclinedDraw |
               Update.DrawDeclined
  gameID: GameID
}

export interface SpecialDrawPreferenceUpdate extends ChessUpdate {
  chessUpdate: Update.SpecialDrawPreference
  gameID: GameID
  setting: boolean
}

export interface UndoUpdate extends ChessUpdate {
  chessUpdate: Update.RequestedUndo |
               Update.UndoRequested |
               Update.RevokedUndo |
               Update.UndoRevoked |
               Update.DeclinedUndo |
               Update.UndoDeclined |
               Update.AcceptedUndo |
               Update.UndoAccepted
  gameID: GameID
}

export interface UndoAcceptedUpdate extends ChessUpdate {
  chessUpdate: Update.AcceptedUndo | Update.UndoAccepted
  gameID: GameID
  position: FENPosition
  undoMoves: number
}

//
// Actions
//

export interface ChessAction {
  'chess-user-action': Action
}

//  Challenges

export interface ChessChallengeAction extends ChessAction {
  'who': Ship
}

export interface ChessSendChallengeAction extends ChessChallengeAction {
  'chess-user-action': Action.SendChallenge
  'challenger-side': Side
  'event': string
}

export interface ChessAcceptChallengeAction extends ChessChallengeAction {
  'chess-user-action': Action.AcceptChallenge
}

export interface ChessDeclineChallengeAction extends ChessChallengeAction {
  'chess-user-action': Action.DeclineChallenge
}

//  Game actions

export interface ChessGameAction extends ChessAction {
  'game-id': GameID
}

//    Resignations

export interface ResignAction extends ChessGameAction {
  'chess-user-action': Action.Resign
}

//    Draws

export interface OfferDrawAction extends ChessGameAction {
  'chess-user-action': Action.OfferDraw
}

export interface RevokeDrawAction extends ChessGameAction {
  'chess-user-action': Action.RevokeDraw
}

export interface DeclineDrawAction extends ChessGameAction {
  'chess-user-action': Action.DeclineDraw
}

export interface AcceptDrawAction extends ChessGameAction {
  'chess-user-action': Action.AcceptDraw
}

export interface ClaimSpecialDrawAction extends ChessGameAction {
  'chess-user-action': Action.ClaimSpecialDraw
}

//    Undos

export interface RequestUndoAction extends ChessGameAction {
  'chess-user-action': Action.RequestUndo
}

export interface DeclineUndoAction extends ChessGameAction {
  'chess-user-action': Action.DeclineUndo
}

export interface AcceptUndoAction extends ChessGameAction {
  'chess-user-action': Action.AcceptUndo
}

export interface RevokeUndoAction extends ChessGameAction {
  'chess-user-action': Action.RevokeUndo
}

//    Moves

export interface ChessMoveAction extends ChessGameAction {
  'chess-user-action': Action.MakeMove
  'chess-move': MoveActionAction
}

export interface MoveAction extends ChessMoveAction {
  'chess-move': MoveActionAction.Move
  'from-rank': Rank
  'from-file': File
  'to-rank': Rank
  'to-file': File
  'into': PromotionRole
}

export interface CastleAction extends ChessMoveAction {
  'chess-move': MoveActionAction.Castle
  'castle-side': CastleSide
}

//    Preferences

export interface ChangeSpecialDrawPreferenceAction extends ChessGameAction {
  'chess-user-action': Action.ChangeSpecialDrawPreference
  'setting': boolean
}

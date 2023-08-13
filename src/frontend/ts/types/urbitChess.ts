import { Key as CgKey } from 'chessground/types'

//
// Enumerations
//

export enum Side {
  White = 'white',
  Black = 'black',
  Random = 'random'
}

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

export enum Result {
  WhiteVictory = '1-0',
  BlackVictory = '0-1',
  Draw = '½–½'
}

export enum Update {
  ChallengeSent = 'challenge-sent',
  ChallengeReceived = 'challenge-received',
  ChallengeResolved = 'challenge-resolved',
  ChallengeReplied = 'challenge-replied',
  Position = 'position',
  Result = 'result',
  DrawOffer = 'draw-offer',
  // DrawRevoked = 'draw-revoked',
  DrawDeclined = 'draw-declined',
  SpecialDrawPreference = 'special-draw-preference',
  UndoRequest = 'undo-request',
  // UndoRevoked = 'undo-revoked',
  UndoDeclined = 'undo-declined',
  UndoAccepted = 'undo-accepted'
}

export enum Action {
  // XX SendChallenge
  Challenge = 'challenge',
  // XX AcceptChallenge
  AcceptGame = 'accept-game',
  // XX DeclineChallenge
  DeclineGame = 'decline-game',
  OfferDraw = 'offer-draw',
  AcceptDraw = 'accept-draw',
  DeclineDraw = 'decline-draw',
  // RevokeDraw = 'revoke-draw',
  // XX rename to MakeMove?
  Move = 'move',
  ChangeSpecialDrawPreference = 'change-special-draw-preference',
  ClaimSpecialDraw = 'claim-special-draw',
  Resign = 'resign',
  RequestUndo = 'request-undo',
  DeclineUndo = 'decline-undo',
  AcceptUndo = 'accept-undo'
  // RevokeUndo = 'revoke-undo'
}

// Yes, I know how retarded 'MoveActionAction.Move' looks - thank Ray for the types in sur/chess.hoon
export enum MoveActionAction {
  Move = 'move',
  Castle = 'castle',
}

//
// Types
//

export type Rank = '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8'
export type File = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'

export type Ship = string

export type GameID = string

export type SAN = string

export type FENPosition = string

export type Move = {
  from: CgKey
  to: CgKey
  san: SAN
  fen: FENPosition
}

export type GameInfo = {
  gameID: GameID,
  event: string, // XX remove
  site: string,  // XX remove
  round: string, // XX remove
  white: Ship,
  black: Ship,
  result: Result,
  moves: Array<Move>
}

export type ActiveGameInfo = {
  // XX game: GameInfo
  position: FENPosition,
  gotDrawOffer: boolean,
  sentDrawOffer: boolean,
  drawClaimAvailable: boolean,
  autoClaimSpecialDraws: boolean,
  gotUndoRequest: boolean,
  sentUndoRequest: boolean,
  info: GameInfo
  // XX Opponent: Ship
}

export type Challenge = {
  who: Ship,
  challengerSide: Side,
  event: string,
  round: string  // XX remove
}

//
// Interfaces
//

// Updates
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
  round: string
}

export interface ChallengeReceivedUpdate extends ChallengeUpdate {
  chessUpdate: Update.ChallengeReceived
  challengerSide: Side
  event: string
  round: string
}

export interface PositionUpdate extends ChessUpdate {
  chessUpdate: Update.Position
  gameID: GameID
  position: FENPosition
  specialDrawAvailable: boolean
  move: Move | null
}

export interface ResultUpdate extends ChessUpdate {
  chessUpdate: Update.Result
  gameID: GameID
  result: Result
}

export interface DrawOfferUpdate extends ChessUpdate {
  chessUpdate: Update.DrawOffer
  gameID: GameID
}

// %draw-revoked

export interface DrawDeclinedUpdate extends ChessUpdate {
  chessUpdate: Update.DrawDeclined
  gameID: GameID
}

export interface SpecialDrawPreferenceUpdate extends ChessUpdate {
  chessUpdate: Update.SpecialDrawPreference
  gameID: GameID
  setting: boolean
}

export interface UndoRequestUpdate extends ChessUpdate {
  chessUpdate: Update.UndoRequest
  gameID: GameID
}

// %undo-revoked

export interface UndoDeclinedUpdate extends ChessUpdate {
  chessUpdate: Update.UndoDeclined
  gameID: GameID
}

export interface UndoAcceptedUpdate extends ChessUpdate {
  chessUpdate: Update.UndoAccepted
  gameID: GameID
  position: FENPosition
  undoMoves: number
}

// Actions
export interface ChessAction {
  'chess-action': Action
}

// XX rename to ChessSendChallengeAction?

export interface ChessChallengeAction extends ChessAction {
  'chess-action': Action.Challenge
  'who': Ship
  'challenger-side': Side
  'event': string
  'round': string
}

// XX rename to ChessAcceptChallengeAction?

export interface ChessAcceptAction extends ChessAction {
  'chess-action': Action.AcceptGame
  'who': Ship
}

// XX rename to ChessDeclineChallengeAction?

export interface ChessDeclineAction extends ChessAction {
  'chess-action': Action.DeclineGame
  'who': Ship
}

export interface ChessGameAction extends ChessAction {
  'game-id': GameID
}

export interface OfferDrawAction extends ChessGameAction {
  'chess-action': Action.OfferDraw
}

export interface AcceptDrawAction extends ChessGameAction {
  'chess-action': Action.AcceptDraw
}

export interface DeclineDrawAction extends ChessGameAction {
  'chess-action': Action.DeclineDraw
}

//  XX %revoke-draw

export interface ChangeSpecialDrawPreferenceAction extends ChessGameAction {
  'chess-action': Action.ChangeSpecialDrawPreference
  'setting': boolean
}

export interface ClaimSpecialDrawAction extends ChessGameAction {
  'chess-action': Action.ClaimSpecialDraw
}

export interface ResignAction extends ChessGameAction {
  'chess-action': Action.Resign
}

export interface RequestUndoAction extends ChessGameAction {
  'chess-action': Action.RequestUndo
}

export interface DeclineUndoAction extends ChessGameAction {
  'chess-action': Action.DeclineUndo
}

export interface AcceptUndoAction extends ChessGameAction {
  'chess-action': Action.AcceptUndo
}

// %revoke-undo

// Moves
export interface MoveAction extends ChessGameAction {
  'chess-action': Action.Move
  'chess-move': MoveActionAction
}

// XX rename to MakeMoveAction?

export interface MoveMoveAction extends MoveAction {
  'chess-move': MoveActionAction.Move
  'from-rank': Rank
  'from-file': File
  'to-rank': Rank
  'to-file': File
  'into': PromotionRole
}

export interface CastleMoveAction extends MoveAction {
  'chess-move': MoveActionAction.Castle
  'castle-side': CastleSide
}

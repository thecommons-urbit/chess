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
  Challenge = 'challenge',
  Position = 'position',
  Result = 'result',
  DrawOffer = 'draw-offer',
  DrawDeclined = 'draw-declined'
}

export enum Action {
  Challenge = 'challenge',
  AcceptGame = 'accept-game',
  DeclineGame = 'decline-game',
  OfferDraw = 'offer-draw',
  AcceptDraw = 'accept-draw',
  DeclineDraw = 'decline-draw',
  Move = 'move'
}

// Yes, I know how retarded 'MoveActionAction.Move' looks - thank Ray for the types in sur/chess.hoon
export enum MoveActionAction {
  Move = 'move',
  Castle = 'castle',
  End = 'end'
}

//
// Types
//

export type Rank = '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8'
export type File = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'

export type Ship = string

export type GameID = string

export type FENPosition = string

export type GameInfo = {
  gameID: GameID,
  event: string,
  site: string,
  round: string,
  white: Ship,
  black: Ship,
  result: Result
}

export type ActiveGameInfo = {
  position: FENPosition,
  gotDrawOffer: boolean,
  sentDrawOffer: boolean,
  info: GameInfo
}

export type Challenge = {
  who: Ship,
  challengerSide: Side,
  event: string,
  round: string
}

//
// Interfaces
//

// Updates
export interface ChessUpdate {
  chessUpdate: Update
}

export interface ChallengeUpdate extends ChessUpdate {
  chessUpdate: Update.Challenge
  who: Ship
  challengerSide: Side
  event: string
  round: string
}

export interface PositionUpdate extends ChessUpdate {
  chessUpdate: Update.Position
  gameID: GameID
  position: FENPosition
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

export interface DrawDeclinedUpdate extends ChessUpdate {
  chessUpdate: Update.DrawDeclined
  gameID: GameID
}

// Actions
export interface ChessAction {
  'chess-action': Action
}

export interface ChessChallengeAction extends ChessAction {
  'chess-action': Action.Challenge
  'who': Ship
  'challenger-side': Side
  'event': string
  'round': string
}

export interface ChessAcceptAction extends ChessAction {
  'chess-action': Action.AcceptGame
  'who': Ship
}

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

// Moves
export interface MoveAction extends ChessGameAction {
  'chess-action': Action.Move
  'chess-move': MoveActionAction
}

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

export interface EndMoveAction extends MoveAction {
  'chess-move': MoveActionAction.End,
  'result': Result
}

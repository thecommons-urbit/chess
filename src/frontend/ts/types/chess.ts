export enum ChessSide {
  White = 'white',
  Black = 'black',
  Random = 'random'
}

export type Ship = string

export type ChessGameID = string

export type ChessPositionFEN = string

export type ChessGameInfo = {
  gameID: ChessGameID,
  event: string,
  site: string,
  round: string,
  white: string,
  black: string,
  result: string
}

export type ChessActiveGameInfo = {
  position: ChessPositionFEN,
  gotDrawOffer: boolean,
  sentDrawOffer: boolean,
  info: ChessGameInfo
}

export type ChessChallenge = {
  who: Ship,
  challengerSide: ChessSide
  event: string,
  round: string
}

export interface ChessUpdate {
  chessUpdate: 'challenge' | 'position' | 'result' | 'draw-offer' | 'draw-declined'
}

export interface ChessChallengeUpdate extends ChessUpdate, ChessChallenge {
  chessUpdate: 'challenge'
}

export interface ChessPositionUpdate extends ChessUpdate {
  chessUpdate: 'position'
  gameID: ChessGameID
  position: ChessPositionFEN
}

export interface ChessResultUpdate extends ChessUpdate {
  chessUpdate: 'result'
  gameID: ChessGameID
  result: '1-0' | '0-1' | '½–½'
}

export interface ChessDrawOfferUpdate extends ChessUpdate {
  chessUpdate: 'draw-offer'
  gameID: ChessGameID
}

export interface ChessDrawDeclinedUpdate extends ChessUpdate {
  chessUpdate: 'draw-declined'
  gameID: ChessGameID
}

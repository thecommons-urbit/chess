import { KNIGHT, BISHOP, ROOK, QUEEN } from 'chess.js'
import * as cg from 'chessground/types'
import { PromotionRole } from '../types/urbitChess'

type Role = typeof QUEEN | typeof ROOK | typeof KNIGHT | typeof BISHOP
type RoleDictionary = {
  cgRole: cg.Role,
  chessRole: Role,
  urbitRole: PromotionRole
}

const DEFAULT_FEN: string = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

const PROMOTION_ROLES: RoleDictionary[] = [
  { cgRole: 'queen', chessRole: QUEEN, urbitRole: PromotionRole.Queen },
  { cgRole: 'rook', chessRole: ROOK, urbitRole: PromotionRole.Rook },
  { cgRole: 'knight', chessRole: KNIGHT, urbitRole: PromotionRole.Knight },
  { cgRole: 'bishop', chessRole: BISHOP, urbitRole: PromotionRole.Bishop }
]

interface PieceValues {
  [key: string]: number;
}

const PIECE_VALUES: PieceValues = {
  'p': 1,
  'n': 3,
  'b': 3,
  'r': 5,
  'q': 9
}

interface PieceIcons {
  [key: string]: string;
}

const PIECE_ICONS_WHITE: PieceIcons = {
  'p': '♙',
  'n': '♘',
  'b': '♗',
  'r': '♖',
  'q': '♕'
}

const PIECE_ICONS_BLACK: PieceIcons = {
  'p': '♟︎',
  'n': '♞',
  'b': '♝',
  'r': '♜',
  'q': '♛'
}

export const CHESS = {
  defaultFEN: DEFAULT_FEN,
  promotionRoles: PROMOTION_ROLES,
  pieceValues: PIECE_VALUES,
  pieceIconsWhite: PIECE_ICONS_WHITE,
  pieceIconsBlack: PIECE_ICONS_BLACK
}

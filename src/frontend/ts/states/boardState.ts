import { ChessInstance } from 'chess.js'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import { Promotion } from '../types/board'

interface BoardState {
  api: CgApi | null;
  chess: ChessInstance | null;
  promotion: Promotion | null;
  baseConfig: CgConfig;
  setApi: (boardApi: CgApi) => void;
  setChess: (chessApi: ChessInstance) => void;
  updatePromotion: (newPromotionData: Promotion | null) => void;
  updateConfig: (newConfig: CgConfig) => void;
}

export default BoardState

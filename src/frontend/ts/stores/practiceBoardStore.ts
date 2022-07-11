import create from 'zustand'
import { ChessInstance } from 'chess.js'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import BoardState from '../states/boardState'
import { ChessConstants } from '../constants'
import { Promotion } from '../types/board'

const usePracticeBoardStore = create<BoardState>((set, get) => ({
  api: null,
  chess: null,
  promotion: null,
  baseConfig: ChessConstants.basePracticeConfig,
  setApi: (boardApi: CgApi) => set({ api: boardApi }),
  setChess: (chessApi: ChessInstance) => set({ chess: chessApi }),
  updatePromotion: (newPromotionData: Promotion | null) => set({ promotion: newPromotionData }),
  updateConfig: (newConfig: CgConfig) => set({ baseConfig: newConfig })
}))

export default usePracticeBoardStore

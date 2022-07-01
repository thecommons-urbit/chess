import create from 'zustand'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import { ChessPositionFEN } from '../types/chess'
import BoardState from '../states/boardState'
import { ChessConstants } from '../constants'

const usePracticeBoardStore = create<BoardState>((set, get) => ({
  api: null,
  fen: ChessConstants.initialFen,
  baseConfig: ChessConstants.basePracticeConfig,
  setApi: (boardApi: CgApi) => set({ api: boardApi }),
  updateFen: (newFen: string) => set({ fen: newFen }),
  updateConfig: (newConfig: CgConfig) => set({ baseConfig: newConfig })
}))

export default usePracticeBoardStore

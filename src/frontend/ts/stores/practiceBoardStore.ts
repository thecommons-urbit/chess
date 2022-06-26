import create from 'zustand'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import { ChessPositionFEN } from '../types/chess'
import BoardState from '../states/boardState'
import ChessConstants from '../constants/chess'

const usePracticeBoardStore = create<BoardState>((set, get) => ({
  fen: ChessConstants.initialFen,
  api: null,
  baseConfig: {},
  setApi: (boardApi: CgApi) => set({ api: boardApi }),
  updateConfig: (newConfig: CgConfig) => set({ baseConfig: newConfig })
}))

export default usePracticeBoardStore

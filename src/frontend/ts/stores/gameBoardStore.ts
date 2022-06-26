import create from 'zustand'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import { ChessPositionFEN } from '../types/chess'
import BoardState from '../states/boardState'
import ChessConstants from '../constants/chess'

const useGameBoardStore = create<BoardState>((set, get) => ({
  fen: ChessConstants.initialFen,
  api: null,
  baseConfig: {},
  setApi: (boardApi: CgApi) => set(state => ({ api: boardApi })),
  updateConfig: (newConfig: CgConfig) => set(state => ({ baseConfig: newConfig }))
}))

export default useGameBoardStore

import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'
import { ChessPositionFEN } from '../types/chess'

interface BoardState {
  fen: ChessPositionFEN;
  api: CgApi | null;
  baseConfig: CgConfig;
  setApi: (boardApi: CgApi) => void;
  updateConfig: (newConfig: CgConfig) => void;
}

export default BoardState

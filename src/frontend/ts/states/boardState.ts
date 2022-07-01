import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'

interface BoardState {
  api: CgApi | null;
  fen: string;
  baseConfig: CgConfig;
  setApi: (boardApi: CgApi) => void;
  updateFen: (newFen: string) => void;
  updateConfig: (newConfig: CgConfig) => void;
}

export default BoardState

import Urbit from '@urbit/http-api'
import { ChessActiveGameInfo, ChessChallenge, ChessChallengeUpdate, ChessGameID, ChessGameInfo, ChessUpdate, Ship } from '../types/chess'

interface ChessState {
  urbit: Urbit | null;
  receivedChallenges: Map<Ship, ChessChallenge>;
  activeGames: Map<ChessGameID, ChessActiveGameInfo>;
  completedGames: Map<ChessGameID, ChessActiveGameInfo>;
  declineDraw: (gameID: ChessGameID) => void;
  offerDraw: (gameID: ChessGameID) => void;
  receiveChallenge: (data: ChessChallengeUpdate) => void;
  receiveGame: (data: ChessGameInfo) => void;
  receiveUpdate: (data: ChessUpdate) => void;
  removeChallenge: (who: Ship) => void;
  setUrbit: (urbit: Urbit) => void;
}

export default ChessState

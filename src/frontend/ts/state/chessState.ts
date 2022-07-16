import Urbit from '@urbit/http-api'
import { Ship, GameID, GameInfo, ActiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate } from '../types/urbitChess'

interface ChessState {
  urbit: Urbit | null;
  displayGame: ActiveGameInfo | null;
  activeGames: Map<GameID, ActiveGameInfo>;
  incomingChallenges: Map<Ship, Challenge>;
  receiveChallenge: (data: ChallengeUpdate) => void;
  receiveGame: (data: GameInfo) => void;
  receiveUpdate: (data: ChessUpdate) => void;
  removeChallenge: (who: Ship) => void;
  declinedDraw: (gameID: GameID) => void;
  offeredDraw: (gameID: GameID) => void;
  setUrbit: (urbit: Urbit) => void;
  setDisplayGame: (displayGame: ActiveGameInfo | null) => void;
}

export default ChessState

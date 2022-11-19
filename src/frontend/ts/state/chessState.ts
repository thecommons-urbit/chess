import Urbit from '@urbit/http-api'
import { Ship, GameID, SAN, FENPosition, Move, GameInfo, ActiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate } from '../types/urbitChess'

interface ChessState {
  // properties
  urbit: Urbit | null
  displayGame: ActiveGameInfo | null
  displayIndex: number | null
  practiceBoard: String | null
  activeGames: Map<GameID, ActiveGameInfo>
  incomingChallenges: Map<Ship, Challenge>
  outgoingChallenges: Map<Ship, Challenge>
  friends: Array<Ship>
  // functions
  setUrbit: (urbit: Urbit) => void
  setDisplayGame: (displayGame: ActiveGameInfo | null) => void
  setDisplayIndex: (displayIndex: number | null) => void
  setPracticeBoard: (practiceBoard: String | null) => void
  setFriends: (friends: Array<Ship>) => void
  receiveChallengeUpdate: (data: ChallengeUpdate) => void
  receiveGame: (data: GameInfo) => void
  receiveUpdate: (data: ChessUpdate) => void
  declinedDraw: (gameID: GameID) => void
  offeredDraw: (gameID: GameID) => void
}

export default ChessState

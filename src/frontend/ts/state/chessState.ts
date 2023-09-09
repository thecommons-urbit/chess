import Urbit from '@urbit/http-api'
import { Ship, GameID, GameInfo, ActiveGameInfo, ArchivedGameInfo, Challenge, ChessUpdate, ChallengeUpdate } from '../types/urbitChess'

interface ChessState {
  // properties
  urbit: Urbit | null
  displayGame: GameInfo | null
  displayIndex: number
  practiceBoard: String | null
  activeGames: Map<GameID, ActiveGameInfo>
  archivedGames: Map<GameID, ArchivedGameInfo>
  incomingChallenges: Map<Ship, Challenge>
  outgoingChallenges: Map<Ship, Challenge>
  friends: Array<Ship>
  // frontend state functions
  setUrbit: (urbit: Urbit) => void
  setDisplayGame: (displayGame: GameInfo | null) => void
  setDisplayIndex: (displayIndex: number) => void
  setPracticeBoard: (practiceBoard: String | null) => void
  setFriends: (friends: Array<Ship>) => void
  fetchArchivedMoves: (gameId: GameID) => void
  displayArchivedGame: (gameId: GameID) => void
  // backend update functions
  receiveChallengeUpdate: (data: ChallengeUpdate) => void
  receiveActiveGame: (data: ActiveGameInfo) => void
  receiveArchivedGame: (data: ArchivedGameInfo) => void
  receiveGameUpdate: (data: ChessUpdate) => void
}

export default ChessState

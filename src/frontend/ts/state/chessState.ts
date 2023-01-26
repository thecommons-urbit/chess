import Urbit from '@urbit/http-api'
import { Ship, GameID, SAN, FENPosition, Move, GameInfo, ActiveGameInfo, ArchiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate } from '../types/urbitChess'

interface ChessState {
  // properties
  urbit: Urbit | null
  displayGame: ActiveGameInfo | ArchiveGameInfo | null
  displayIndex: number | null
  practiceBoard: String | null
  activeGames: Map<GameID, ActiveGameInfo>
  localArchive: Map<GameID, ArchiveGameInfo>
  showingArchive: boolean,
  setShowingArchive: (toggle: boolean) => void
  incomingChallenges: Map<Ship, Challenge>
  outgoingChallenges: Map<Ship, Challenge>
  friends: Array<Ship>
  // functions
  setUrbit: (urbit: Urbit) => void
  setDisplayGame: (displayGame: ActiveGameInfo | ArchiveGameInfo | null) => void
  setDisplayIndex: (displayIndex: number | null) => void
  setPracticeBoard: (practiceBoard: String | null) => void
  setFriends: (friends: Array<Ship>) => void
  setLocalArchive: (data: Array<GameInfo>) => void
  receiveChallengeUpdate: (data: ChallengeUpdate) => void
  receiveGame: (data: GameInfo) => void
  receiveUpdate: (data: ChessUpdate) => void
  declinedDraw: (gameID: GameID) => void
  offeredDraw: (gameID: GameID) => void
}

export default ChessState

import create from 'zustand'
import Urbit from '@urbit/http-api'
import { CHESS } from '../constants/chess'
import { Action, Update, Ship, GameID, GameInfo, ActiveGameInfo, ArchivedGameInfo, Challenge, ChessUpdate, ChallengeUpdate, ChallengeSentUpdate, ChallengeReceivedUpdate, PositionUpdate, ResultUpdate, DrawUpdate, SpecialDrawPreferenceUpdate, UndoUpdate, UndoAcceptedUpdate } from '../types/urbitChess'
import { scryFriends, scryMoves } from '../helpers/urbitChess'
import ChessState from './chessState'

// TODO: should log which function was called with the bad ID
// TODO: should check if the ID is a valid archived game
const badGameId = (gameID: GameID) => {
  console.log('received bad gameId: ' + gameID)
}

const useChessStore = create<ChessState>((set, get) => ({
  urbit: null,
  displayGame: null,
  practiceBoard: '',
  activeGames: new Map(),
  archivedGames: new Map(),
  incomingChallenges: new Map(),
  outgoingChallenges: new Map(),
  friends: [],
  displayIndex: 0,
  //
  setUrbit: (urbit: Urbit) => set({ urbit }),
  setDisplayGame: (displayGame: GameInfo | null) => {
    const newIndex = ((displayGame !== null) && Array.isArray(displayGame.moves) && displayGame.moves.length > 0)
      ? (displayGame.moves.length - 1)
      : 0

    set({ displayGame, displayIndex: newIndex })
  },
  setPracticeBoard: (practiceBoard: String | null) => set({ practiceBoard }),
  setFriends: async (friends: Array<Ship>) => set({ friends }),
  setDisplayIndex: (displayIndex: number) => {
    set({ displayIndex })
  },
  //
  receiveChallengeUpdate: (data: ChallengeUpdate) => {
    switch (data.chessUpdate) {
      case Update.ChallengeSent: {
        set(state => ({ outgoingChallenges: state.outgoingChallenges.set(data.who, data as ChallengeSentUpdate) }))
        break
      }
      case Update.ChallengeReceived: {
        set(state => ({ incomingChallenges: state.incomingChallenges.set(data.who, data as ChallengeReceivedUpdate) }))
        break
      }
      case Update.ChallengeReplied: {
        let incomingChallenges: Map<Ship, Challenge> = get().incomingChallenges
        incomingChallenges.delete(data.who)

        set({ incomingChallenges })
        break
      }
      case Update.ChallengeResolved: {
        let outgoingChallenges: Map<Ship, Challenge> = get().outgoingChallenges
        outgoingChallenges.delete(data.who)

        set({ outgoingChallenges })
        break
      }
      default: {
        console.log('RECEIVED BAD CHALLENGE UPDATE')
        console.log(data.chessUpdate)
        console.log(data.who)
      }
    }
  },
  receiveActiveGame: async (data: ActiveGameInfo) => {
    set(state => ({ activeGames: state.activeGames.set(data.gameID, data) }))

    await get().urbit.subscribe({
      app: 'chess',
      path: `/game/${data.gameID}/updates`,
      err: () => {},
      event: (data: ChessUpdate) => get().receiveGameUpdate(data),
      quit: () => {}
    })
  },
  receiveArchivedGame: async (data: ArchivedGameInfo) => {
    set(state => ({ archivedGames: state.archivedGames.set(data.gameID, data) }))
  },
  fetchArchivedMoves: async (gameID: GameID) => {
    const currentGame = get().archivedGames.get(gameID)

    if (currentGame === null) {
      badGameId(gameID)
      return
    }

    //  TODO: resolve this so that only the first condition is necessary
    if (currentGame.moves === null || currentGame.moves.length === 0) {
      const movesData = await scryMoves('chess', '/game/' + gameID + '/moves')

      const archivedGame: ArchivedGameInfo = {
        ...currentGame,
        moves: movesData
      }

      set(state => ({ archivedGames: state.archivedGames.set(gameID, archivedGame) }))
    }
  },
  displayArchivedGame: async (gameID: GameID) => {
    const currentGame = get().archivedGames.get(gameID)

    if (currentGame === null) {
      badGameId(gameID)
      return
    }

    await get().fetchArchivedMoves(gameID)
    get().setDisplayGame(get().archivedGames.get(gameID))
  },
  receiveGameUpdate: (data: ChessUpdate) => {
    const updateDisplayGame = (updatedGame: ActiveGameInfo) => {
      const displayGame = get().displayGame
      if ((displayGame !== null) && (updatedGame.gameID === displayGame.gameID)) {
        set({ displayGame: updatedGame })
      }
    }

    switch (data.chessUpdate) {
      case Update.Position: {
        const positionData = data as PositionUpdate
        const gameID = positionData.gameID
        const move = positionData.move
        const currentGame = get().activeGames.get(gameID)

        if (currentGame === null) {
          badGameId(gameID)
          return
        }

        if (move.san !== null && move.fen !== null) {
          currentGame.moves.push(move)

          const updatedGame: ActiveGameInfo = {
            ...currentGame,
            position: move.fen,
            drawClaimAvailable: positionData.specialDrawAvailable
          }
          // Math.max() gives a zero default in case currentGame moves is null
          const newIndex: number = Math.max(currentGame.moves.length - 1, 0)

          set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame), displayIndex: newIndex }))
          updateDisplayGame(updatedGame)

          console.log('RECEIVED POSITION UPDATE FOR ' + gameID)
        }

        break
      }

      case Update.Result: {
        const resultData = data as ResultUpdate
        const gameID = resultData.gameID
        const currentGame = get().activeGames.get(gameID)
        //  this game already exists in archivedGame, because of the
        //  ordering of cards coming from %chess
        const archivedGame = get().archivedGames.get(gameID)

        //  copy moves to archived version before deleting
        const updatedGame: ArchivedGameInfo = {
          ...archivedGame,
          moves: currentGame.moves
        }

        var activeGames: Map<GameID, ActiveGameInfo> = get().activeGames
        activeGames.delete(gameID)

        set(state => ({
          activeGames: activeGames,
          archivedGames: state.archivedGames.set(gameID, updatedGame)
        }))

        // display the archived version
        if (gameID === get().displayGame.gameID) {
          get().setDisplayGame(updatedGame)
        }

        console.log('RECEIVED RESULT UPDATE ' + resultData.result + ' FOR ' + gameID)
        break
      }

      case Update.OfferedDraw:
      case Update.DrawOffered:
      case Update.RevokedDraw:
      case Update.DrawRevoked:
      case Update.DeclinedDraw:
      case Update.DrawDeclined: {
        const drawData = data as DrawUpdate
        const gameID = drawData.gameID
        const currentGame = get().activeGames.get(gameID)

        if (currentGame === null) {
          badGameId(gameID)
          return
        }

        const gotDrawOffer = (() => {
          switch (drawData.chessUpdate) {
            case Update.DrawOffered: { return true }
            case Update.DrawRevoked: { return false }
            case Update.DeclinedDraw: { return false }
            default: { return currentGame.gotDrawOffer }
          }
        })()
        const sentDrawOffer = (() => {
          switch (drawData.chessUpdate) {
            case Update.OfferedDraw: { return true }
            case Update.RevokedDraw: { return false }
            case Update.DrawDeclined: { return false }
            default: { return currentGame.sentDrawOffer }
          }
        })()

        const updatedGame: ActiveGameInfo = {
          ...currentGame,
          gotDrawOffer: gotDrawOffer,
          sentDrawOffer: sentDrawOffer
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED DRAW UPDATE ' + data.chessUpdate + ' FOR ' + gameID)
        break
      }

      case Update.SpecialDrawPreference: {
        const preferenceData = data as SpecialDrawPreferenceUpdate
        const gameID = preferenceData.gameID
        const setting = preferenceData.setting
        const currentGame = get().activeGames.get(gameID)

        if (currentGame === null) {
          badGameId(gameID)
          return
        }

        const updatedGame: ActiveGameInfo = {
          ...currentGame,
          autoClaimSpecialDraws: setting
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED SPECIAL DRAW PREFERENCE UPDATE ' + setting + ' FOR ' + gameID)
        break
      }

      case Update.RequestedUndo:
      case Update.UndoRequested:
      case Update.RevokedUndo:
      case Update.UndoRevoked:
      case Update.DeclinedUndo:
      case Update.UndoDeclined: {
        const undoData = data as UndoUpdate
        const gameID = undoData.gameID
        const currentGame = get().activeGames.get(gameID)

        if (currentGame === null) {
          badGameId(gameID)
          return
        }

        const gotUndoRequest = (() => {
          switch (undoData.chessUpdate) {
            case Update.UndoRequested: { return true }
            case Update.UndoRevoked: { return false }
            case Update.DeclinedUndo: { return false }
            default: { return currentGame.gotUndoRequest }
          }
        })()
        const sentUndoRequest = (() => {
          switch (undoData.chessUpdate) {
            case Update.RequestedUndo: { return true }
            case Update.RevokedUndo: { return false }
            case Update.UndoDeclined: { return false }
            default: { return currentGame.sentUndoRequest }
          }
        })()

        const updatedGame: ActiveGameInfo = {
          ...currentGame,
          gotUndoRequest: gotUndoRequest,
          sentUndoRequest: sentUndoRequest
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED UNDO UPDATE ' + data.chessUpdate + ' FOR ' + gameID)
        break
      }

      case Update.AcceptedUndo:
      case Update.UndoAccepted: {
        const undoData = data as UndoAcceptedUpdate
        const gameID = undoData.gameID
        const currentGame = get().activeGames.get(gameID)
        if (currentGame === null) {
          badGameId(gameID)
          return
        }

        currentGame.moves.splice(currentGame.moves.length - undoData.undoMoves, undoData.undoMoves)
        const updatedGame: ActiveGameInfo = {
          ...currentGame,
          position: undoData.position,
          gotUndoRequest: false,
          sentUndoRequest: false
        }
        // Math.max() gives a zero default in case currentGame moves is null
        const newIndex: number = Math.max(currentGame.moves.length - 1, 0)

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame), displayIndex: newIndex }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED ACCEPTED UNDO UPDATE FOR ' + gameID)
        break
      }

      default: {
        console.log('RECEIVED BAD UPDATE')
        console.log(data.chessUpdate)
      }
    }
  }
}))

export default useChessStore

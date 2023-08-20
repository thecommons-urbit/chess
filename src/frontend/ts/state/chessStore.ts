import create from 'zustand'
import Urbit from '@urbit/http-api'
import { CHESS } from '../constants/chess'
import { Action, Update, Ship, GameID, GameInfo, ActiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate, ChallengeSentUpdate, ChallengeReceivedUpdate, PositionUpdate, ResultUpdate, DrawUpdate, SpecialDrawPreferenceUpdate, UndoUpdate, UndoAcceptedUpdate } from '../types/urbitChess'
import { findFriends } from '../helpers/urbitChess'
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
  incomingChallenges: new Map(),
  outgoingChallenges: new Map(),
  friends: [],
  displayIndex: null,
  //
  setUrbit: (urbit: Urbit) => set({ urbit }),
  setDisplayGame: (displayGame: ActiveGameInfo | null) => {
    set({ displayGame, displayIndex: null })
  },
  setPracticeBoard: (practiceBoard: String | null) => set({ practiceBoard }),
  setFriends: async (friends: Array<Ship>) => set({ friends }),
  setDisplayIndex: (displayIndex: number | null) => {
    set({ displayIndex })
    console.log('setDisplayIndex displayIndex: ' + displayIndex)
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
  receiveGame: async (data: GameInfo) => {
    const activeGame: ActiveGameInfo = {
      position: CHESS.defaultFEN,
      gotDrawOffer: false,
      sentDrawOffer: false,
      drawClaimAvailable: false,
      autoClaimSpecialDraws: false,
      gotUndoRequest: false,
      sentUndoRequest: false,
      info: data
    }

    set(state => ({ activeGames: state.activeGames.set(data.gameID, activeGame) }))

    await get().urbit.subscribe({
      app: 'chess',
      path: `/game/${data.gameID}/updates`,
      err: () => {},
      event: (data: ChessUpdate) => get().receiveGameUpdate(data),
      quit: () => {}
    })
  },
  receiveGameUpdate: (data: ChessUpdate) => {
    const updateDisplayGame = (updatedGame: ActiveGameInfo) => {
      const displayGame = get().displayGame
      if ((displayGame !== null) && (updatedGame.info.gameID === displayGame.info.gameID)) {
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
          currentGame.info.moves.push(move)

          const updatedGame: ActiveGameInfo = {
            position: move.fen,
            gotDrawOffer: currentGame.gotDrawOffer,
            sentDrawOffer: currentGame.sentDrawOffer,
            drawClaimAvailable: positionData.specialDrawAvailable,
            autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
            gotUndoRequest: currentGame.gotUndoRequest,
            sentUndoRequest: currentGame.sentUndoRequest,
            info: currentGame.info
          }

          set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame), displayIndex: null }))
          updateDisplayGame(updatedGame)

          console.log('RECEIVED POSITION UPDATE FOR ' + gameID)
          console.log('Update.Position displayIndex: ' + (get().displayIndex))
          console.log('Update.Position fen: ' + move.fen)
        }

        break
      }

      case Update.Result: {
        const resultData = data as ResultUpdate
        const gameID = resultData.gameID

        const displayGame = get().displayGame
        if ((displayGame !== null) && (gameID === displayGame.info.gameID)) {
          get().setDisplayGame(null)
        }

        var activeGames: Map<GameID, ActiveGameInfo> = get().activeGames
        activeGames.delete(gameID)

        set({ activeGames })

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
          position: currentGame.position,
          gotDrawOffer: gotDrawOffer,
          sentDrawOffer: sentDrawOffer,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
          gotUndoRequest: currentGame.gotUndoRequest,
          sentUndoRequest: currentGame.sentUndoRequest,
          info: currentGame.info
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
          position: currentGame.position,
          gotDrawOffer: currentGame.gotDrawOffer,
          sentDrawOffer: currentGame.sentDrawOffer,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: setting,
          gotUndoRequest: currentGame.gotUndoRequest,
          sentUndoRequest: currentGame.sentUndoRequest,
          info: currentGame.info
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
          position: currentGame.position,
          gotDrawOffer: currentGame.gotDrawOffer,
          sentDrawOffer: currentGame.sentDrawOffer,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
          gotUndoRequest: gotUndoRequest,
          sentUndoRequest: sentUndoRequest,
          info: currentGame.info
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

        currentGame.info.moves.splice(currentGame.info.moves.length - undoData.undoMoves, undoData.undoMoves)
        const updatedGame: ActiveGameInfo = {
          position: undoData.position,
          gotDrawOffer: currentGame.gotDrawOffer,
          sentDrawOffer: currentGame.sentDrawOffer,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
          gotUndoRequest: false,
          sentUndoRequest: false,
          info: currentGame.info
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame), displayIndex: null }))
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

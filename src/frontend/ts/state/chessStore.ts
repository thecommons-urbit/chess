import create from 'zustand'
import Urbit from '@urbit/http-api'
import { CHESS } from '../constants/chess'
import { Update, Ship, GameID, SAN, FENPosition, Move, GameInfo, ActiveGameInfo, ArchiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate, ChallengeSentUpdate, ChallengeReceivedUpdate, PositionUpdate, ResultUpdate, DrawOfferUpdate, DrawDeclinedUpdate, SpecialDrawPreferenceUpdate } from '../types/urbitChess'
import { findFriends, scryArchive } from '../helpers/urbitChess'
import ChessState from './chessState'

const useChessStore = create<ChessState>((set, get) => ({
  urbit: null,
  displayGame: null,
  practiceBoard: '',
  activeGames: new Map(),
  localArchive: new Map(),
  showingArchive: false,
  setShowingArchive: (toggle: boolean) => set({ showingArchive: toggle }),
  incomingChallenges: new Map(),
  outgoingChallenges: new Map(),
  friends: [],
  displayIndex: null,
  setUrbit: (urbit: Urbit) => set({ urbit }),
  setDisplayGame: (displayGame: ActiveGameInfo | ArchiveGameInfo | null) => {
    set({ displayGame, displayIndex: null })
  },
  setPracticeBoard: (practiceBoard: String | null) => set({ practiceBoard }),
  setFriends: async (friends: Array<Ship>) => set({ friends }),
  setDisplayIndex: (displayIndex: number | null) => {
    set({ displayIndex })
    console.log('setDisplayIndex displayIndex: ' + displayIndex)
  },
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
      case Update.ChallengeResolved: {
        let outgoingChallenges: Map<Ship, Challenge> = get().outgoingChallenges
        outgoingChallenges.delete(data.who)

        set({ outgoingChallenges })
        break
      }
      case Update.ChallengeReplied: {
        let incomingChallenges: Map<Ship, Challenge> = get().incomingChallenges
        incomingChallenges.delete(data.who)

        set({ incomingChallenges })
        break
      }
      default: {
        console.log('RECEIVED BAD UPDATE')
        console.log(data.chessUpdate)
        console.log((data as ChallengeUpdate).chessUpdate)
        console.log((data as ChallengeUpdate).who)
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
      info: data
    }

    set(state => ({ activeGames: state.activeGames.set(data.gameID, activeGame) }))

    await get().urbit.subscribe({
      app: 'chess',
      path: `/game/${data.gameID}/updates`,
      err: () => {},
      event: (data: ChessUpdate) => get().receiveUpdate(data),
      quit: () => {}
    })
  },
  setLocalArchive: async (data: Array<GameInfo>) => {
    if (data !== null) {
      for (const game of data) {
        const archiveGame: ArchiveGameInfo = {
          //  fen of the last move
          position: game.moves[game.moves.length -1].fen,
          gotDrawOffer: false,
          sentDrawOffer: false,
          drawClaimAvailable: false,
          autoClaimSpecialDraws: false,
          info: game
        }

        set(state => ({ localArchive: state.localArchive.set(game.gameID, archiveGame) }))
      }
    }
  },
  //  XX: will this blow things up?
  receiveUpdate: (data: ChessUpdate) => {
    const updateDisplayGame = (updatedGame: ActiveGameInfo) => {
      if ((get().displayGame !== null) && (updatedGame.info.gameID === get().displayGame.info.gameID)) {
        set({ displayGame: updatedGame, displayIndex: null })
      }
    }

    switch (data.chessUpdate) {
      case Update.Position: {
        const positionData = data as PositionUpdate
        const gameID = positionData.gameID
        const move = positionData.move
        const currentGame = get().activeGames.get(gameID)

        if (move.san !== null && move.fen !== null) {
          currentGame.info.moves.push(move)

          const updatedGame: ActiveGameInfo = {
            position: move.fen,
            gotDrawOffer: currentGame.gotDrawOffer,
            sentDrawOffer: currentGame.sentDrawOffer,
            drawClaimAvailable: positionData.specialDrawAvailable,
            autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
            info: currentGame.info
          }

          set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
          updateDisplayGame(updatedGame)

          console.log('RECEIVED POSITION UPDATE')
          console.log('Update.Position displayIndex: ' + (get().displayIndex))
          console.log('Update.Position fen: ' + move.fen)
        }

        break
      }

      case Update.Result: {
        const resultData = data as ResultUpdate
        const gameID = resultData.gameID
        const displayGame = get().displayGame

        const displayLastGame = async () => {
          //
          //  XX: make sure setting localArchive doesn't wipe an existing
          //      archive search result.
          //      maybe results have their own place in state?
          //
          //  get().setLocalArchive(await scryArchive('chess', '/archive/last/8'))
          get().setLocalArchive(await scryArchive('chess', '/archive/all'))

          const lastGame = get().localArchive.get(gameID)
          if ((displayGame !== null) && (gameID === displayGame.info.gameID)) {
            get().setDisplayGame(lastGame)
          }
        }

        displayLastGame()

        var activeGames: Map<GameID, ActiveGameInfo> = get().activeGames
        activeGames.delete(gameID)

        set({ activeGames })

        console.log('RECEIVED RESULT UPDATE')
        break
      }

      case Update.DrawOffer: {
        const offerData = data as DrawOfferUpdate
        const gameID = offerData.gameID

        const currentGame = get().activeGames.get(gameID)
        const updatedGame: ActiveGameInfo = {
          position: currentGame.position,
          gotDrawOffer: true,
          sentDrawOffer: currentGame.sentDrawOffer,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
          info: currentGame.info
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED DRAW OFFER UPDATE')
        break
      }

      case Update.DrawDeclined: {
        const declineData = data as DrawDeclinedUpdate
        const gameID = declineData.gameID

        const currentGame = get().activeGames.get(gameID)
        const updatedGame: ActiveGameInfo = {
          position: currentGame.position,
          gotDrawOffer: currentGame.gotDrawOffer,
          sentDrawOffer: false,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: currentGame.autoClaimSpecialDraws,
          info: currentGame.info
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED DRAW DECLINE UPDATE')
        break
      }
      case Update.SpecialDrawPreference: {
        const preferenceData = data as SpecialDrawPreferenceUpdate
        const gameID = preferenceData.gameID
        const setting = preferenceData.setting

        const currentGame = get().activeGames.get(gameID)
        const updatedGame: ActiveGameInfo = {
          position: currentGame.position,
          gotDrawOffer: currentGame.gotDrawOffer,
          sentDrawOffer: currentGame.sentDrawOffer,
          drawClaimAvailable: currentGame.drawClaimAvailable,
          autoClaimSpecialDraws: setting,
          info: currentGame.info
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED SPECIAL DRAW PREFERENCE UPDATE')
        break
      }
      default: {
        console.log('RECEIVED BAD UPDATE')
        console.log(data.chessUpdate)
        console.log((data as PositionUpdate).gameID)
        console.log((data as PositionUpdate).position)
      }
    }
  },
  declinedDraw: (gameID: GameID) => {
    let updatedGame: ActiveGameInfo = get().activeGames.get(gameID)
    updatedGame.gotDrawOffer = false

    set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
  },
  offeredDraw: (gameID: GameID) => {
    let updatedGame: ActiveGameInfo = get().activeGames.get(gameID)
    updatedGame.sentDrawOffer = true

    set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
  }
}))

export default useChessStore

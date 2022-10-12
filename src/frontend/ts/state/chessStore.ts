import create from 'zustand'
import Urbit from '@urbit/http-api'
import { CHESS } from '../constants/chess'
import { Update, Ship, GameID, GameInfo, ActiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate, PositionUpdate, ResultUpdate, DrawOfferUpdate, DrawDeclinedUpdate } from '../types/urbitChess'
import ChessState from './chessState'

const useChessStore = create<ChessState>((set, get) => ({
  urbit: null,
  displayGame: null,
  practiceBoard: '',
  activeGames: new Map(),
  incomingChallenges: new Map(),
  setUrbit: (urbit: Urbit) => set({ urbit }),
  setDisplayGame: (displayGame: ActiveGameInfo | null) => set({ displayGame }),
  setPracticeBoard: (practiceBoard: String | null) => set({ practiceBoard }),
  receiveChallenge: (data: ChallengeUpdate) =>
    set(state => ({ incomingChallenges: state.incomingChallenges.set(data.who, data as Challenge) })),
  receiveGame: async (data: GameInfo) => {
    const activeGame: ActiveGameInfo = {
      position: CHESS.defaultFEN,
      gotDrawOffer: false,
      sentDrawOffer: false,
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
  receiveUpdate: (data: ChessUpdate) => {
    const updateDisplayGame = (updatedGame: ActiveGameInfo) => {
      const displayGame = get().displayGame

      if ((displayGame !== null) && (updatedGame.info.gameID === displayGame.info.gameID)) {
        get().setDisplayGame(updatedGame)
      }
    }

    switch (data.chessUpdate) {
      case Update.Position: {
        const positionData = data as PositionUpdate
        const gameID = positionData.gameID

        const currentGame = get().activeGames.get(gameID)
        const updatedGame: ActiveGameInfo = {
          position: positionData.position,
          gotDrawOffer: currentGame.gotDrawOffer,
          sentDrawOffer: currentGame.sentDrawOffer,
          info: currentGame.info
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED POSITION UPDATE')
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
          info: currentGame.info
        }

        set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
        updateDisplayGame(updatedGame)

        console.log('RECEIVED DRAW DECLINE UPDATE')
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
  removeChallenge: (who: Ship) => {
    let incomingChallenges: Map<Ship, Challenge> = get().incomingChallenges
    incomingChallenges.delete(who)

    set({ incomingChallenges })
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

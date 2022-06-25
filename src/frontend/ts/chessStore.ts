import create from 'zustand'
import Urbit from '@urbit/http-api'
import { ChessActiveGameInfo, ChessChallenge, ChessChallengeUpdate, ChessDrawDeclinedUpdate, ChessDrawOfferUpdate, ChessGameID, ChessGameInfo, ChessPositionUpdate, ChessResultUpdate, ChessUpdate, Ship } from './types'

interface ChessStore {
  urbit: Urbit | null;
  receivedChallenges: Map<Ship, ChessChallenge>;
  activeGames: Map<ChessGameID, ChessActiveGameInfo>;
  completedGames: Map<ChessGameID, ChessActiveGameInfo>;
  practicePos: string;
  updatePracticePos: (newPos: string) => void;
  declineDraw: (gameID: ChessGameID) => void;
  offerDraw: (gameID: ChessGameID) => void;
  receiveChallenge: (data: ChessChallengeUpdate) => void;
  receiveGame: (data: ChessGameInfo) => void;
  receiveUpdate: (data: ChessUpdate) => void;
  removeChallenge: (who: Ship) => void;
  setUrbit: (urbit: Urbit) => void;
}

const useStore = create<ChessStore>((set, get) => ({
  urbit: null,
  receivedChallenges: new Map(),
  activeGames: new Map(),
  completedGames: new Map(),
  practicePos: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR',
  updatePracticePos: (newPos: string) => {
    set(state => ({ practicePos: newPos }))
  },
  declineDraw: (gameID: ChessGameID) => {
    let updatedGame: ChessActiveGameInfo = get().activeGames.get(gameID)
    updatedGame.gotDrawOffer = false

    set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
  },
  offerDraw: (gameID: ChessGameID) => {
    let updatedGame: ChessActiveGameInfo = get().activeGames.get(gameID)
    updatedGame.sentDrawOffer = true

    set(state => ({ activeGames: state.activeGames.set(gameID, updatedGame) }))
  },
  receiveChallenge: (data: ChessChallengeUpdate) =>
    set(state => ({ receivedChallenges: state.receivedChallenges.set(data.who, data as ChessChallenge) })),

  receiveGame: async (data: ChessGameInfo) => {
    const activeGame: ChessActiveGameInfo = {
      position: '',
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
    switch (data.chessUpdate) {
      case 'position': {
        let positionData = data as ChessPositionUpdate

        let updatedGame: ChessActiveGameInfo = get().activeGames.get(positionData.gameID)
        updatedGame.position = positionData.position

        set(state => ({ activeGames: state.activeGames.set(positionData.gameID, updatedGame) }))

        break
      }
      case 'result': {
        let resultData = data as ChessResultUpdate

        let activeGames: Map<ChessGameID, ChessActiveGameInfo> = get().activeGames

        const completedGames: Map<ChessGameID, ChessActiveGameInfo> = get().completedGames.set(resultData.gameID, activeGames.get(resultData.gameID))
        activeGames.delete(resultData.gameID)

        set({ activeGames, completedGames })

        break
      }
      case 'draw-offer': {
        let offerData = data as ChessDrawOfferUpdate

        let updatedGame: ChessActiveGameInfo = get().activeGames.get(offerData.gameID)
        updatedGame.gotDrawOffer = true

        set(state => ({ activeGames: state.activeGames.set(offerData.gameID, updatedGame) }))

        break
      }
      case 'draw-declined': {
        let declineData = data as ChessDrawDeclinedUpdate

        let updatedGame: ChessActiveGameInfo = get().activeGames.get(declineData.gameID)
        updatedGame.sentDrawOffer = false

        set(state => ({ activeGames: state.activeGames.set(declineData.gameID, updatedGame) }))

        break
      }
    }
  },
  removeChallenge: (who: Ship) => {
    let receivedChallenges: Map<Ship, ChessChallenge> = get().receivedChallenges
    receivedChallenges.delete(who)

    set({ receivedChallenges })
  },
  setUrbit: (urbit: Urbit) => set({ urbit })
}))

export default useStore

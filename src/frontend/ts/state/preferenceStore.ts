import create from 'zustand'
import PreferenceState from './preferenceState'

const usePreferenceStore = create<PreferenceState>((set) => ({
  pieceTheme: 'cardinal',
  boardTheme: 'default',
  setPieceTheme: (theme: string) => set(() => ({ pieceTheme: theme })),
  setBoardTheme: (theme: string) => set(() => ({ boardTheme: theme }))
}))

export default usePreferenceStore

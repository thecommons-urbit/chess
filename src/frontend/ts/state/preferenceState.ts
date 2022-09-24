interface PreferenceState {
  pieceTheme: string | null;
  boardTheme: string | null;
  setPieceTheme: (theme: string) => void;
  setBoardTheme: (theme: string) => void;
}

export default PreferenceState

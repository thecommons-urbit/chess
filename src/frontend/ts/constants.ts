const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

const baseGameConfig = {}

const basePracticeConfig =
{
  orientation: 'white' as const,
  coordinates: true,
  autoCastle: true,
  highlight: {
    lastMove: true,
    check: true
  },
  animation: {
    enabled: true,
    duration: 200
  },
  movable: {
    free: false,
    showDests: true,
    rookCastle: false
  },
  premovable: {
    enabled: false
  },
  predroppable: {
    enabled: false
  },
  draggable: {
    enabled: true,
    distance: 3,
    autoDistance: false,
    showGhost: true,
    deleteOnDropoff: false
  },
  selectable: {
    enabled: true
  },
  drawable: {
    enabled: true,
    visible: true,
    defaultSnapToValidMove: true,
    eraseOnClick: true
  }
}

export const ChessConstants = {
  initialFen: initialFen,
  baseGameConfig: baseGameConfig,
  basePracticeConfig: basePracticeConfig
}

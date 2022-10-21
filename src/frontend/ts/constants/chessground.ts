const BASE_CONFIG =
{
  pgn: 'e4 c5 Nf3 d6 e5 Nc6 exd6 Qxd6 Nc3 Nf6', // test pgn XX pass dynamic pgn in
  coordinates: true,
  autoCastle: true,
  viewOnly: false,
  highlight: {
    lastMove: true,
    check: true
  },
  animation: {
    enabled: true,
    duration: 250
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

export const CHESSGROUND = {
  baseConfig: BASE_CONFIG
}

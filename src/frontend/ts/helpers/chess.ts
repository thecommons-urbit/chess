import { ChessInstance, Square, SQUARES, WHITE, PAWN } from 'chess.js'

export function getChessDests (chess: ChessInstance): Map<string, string[]> {
  const dests = new Map<string, string[]>()

  SQUARES.forEach(function (s: Square) {
    const ms = chess.moves({ square: s, verbose: true })
    if (ms.length) {
      dests.set(s, ms.map(m => m.to))
    }
  })

  return dests
}

export function isChessPromotion (orig: Square, dest: Square, chess: ChessInstance): boolean {
  const destRank = dest.charAt(1)

  if ((chess.get(orig).type === PAWN) && ((destRank === '1') || (destRank === '8'))) {
    return true
  }

  return false
}

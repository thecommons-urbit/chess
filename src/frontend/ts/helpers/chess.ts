import { ChessInstance, Square, SQUARES, WHITE, PAWN } from 'chess.js'
import { Ship, Results } from '../types/urbitChess'

/**
 * Determine if a chess move is a pawn promotion
 */
export function isChessPromotion (orig: Square, dest: Square, chess: ChessInstance): boolean {
  const destRank = dest.charAt(1)

  if ((chess.get(orig).type === PAWN) && ((destRank === '1') || (destRank === '8'))) {
    return true
  }

  return false
}

/**
 * Use chess.js to compute the complete list of valid moves for the current FEN
 */
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

export function getTallies (ship: Ship, results: Results): Map<Ship, String> {
  // initialize map to output
  const outputTallies: Map<Ship, String> = new Map();

  // count wins and losses
  const winsWhole = results.wins + Math.floor(results.draws / 2);
  const lossesWhole = results.losses + Math.floor(results.draws / 2);
  // count draws
  const winsFraction = (results.draws % 2) === 1 ? "½" : "";
  const lossesFraction = (results.draws % 2) === 1 ? "½" : "";

  // output final tally
  outputTallies.set(ship, `${lossesWhole}${lossesFraction} - ${winsWhole}${winsFraction}`);

  return outputTallies
}

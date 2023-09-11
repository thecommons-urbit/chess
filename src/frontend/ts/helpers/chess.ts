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

export function getTally (ship: Ship, results: Results): String {
  // console.log('ship')
  // console.log(ship)
  // console.log('results')
  // console.log(results)
  // // initialize map to output
  // const outputTallies: Map<Ship, String> = new Map();
  // console.log('outputTallies')
  // console.log(outputTallies)

  // // XX Output '0 - 0' if Results is { 0, 0, 0 }

  // // count wins and losses
  // const winsWhole = results.wins + Math.floor(results.draws / 2);
  // console.log('winsWhole')
  // console.log(winsWhole)
  // const lossesWhole = results.losses + Math.floor(results.draws / 2);
  // console.log('lossesWhole')
  // console.log(lossesWhole)
  // // count draws
  // const winsFraction = (results.draws % 2) === 1 ? "½" : "";
  // console.log('winsFraction')
  // console.log(winsFraction)
  // const lossesFraction = (results.draws % 2) === 1 ? "½" : "";
  // console.log('lossesFraction')
  // console.log(lossesFraction)

  // // output final tally
  // outputTallies.set(ship, `${lossesWhole}${lossesFraction} - ${winsWhole}${winsFraction}`);
  // console.log('outputTallies')
  // console.log(outputTallies)

  const outputTally: String = '420 - 69'

  return outputTally
}

import * as cg from 'chessground/types'

/**
 * Convert chess.js side/turn color to Chessground side/turn color
 */
export function getCgColor (color: string): cg.Color {
  return (color === 'w') ? 'white' as const : 'black' as const
}

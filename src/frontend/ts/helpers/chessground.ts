import * as cg from 'chessground/types'

export function getCgColor (color: string): cg.Color {
  return (color === 'w') ? 'white' as const : 'black' as const
}

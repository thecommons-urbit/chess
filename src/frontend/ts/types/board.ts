import * as cg from 'chessground/types'

export interface Promotion {
  orig: cg.Key;
  dest: cg.Key;
  color: cg.Color;
  orientation: cg.Color;
}

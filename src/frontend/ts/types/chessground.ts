import { Key as CgKey } from 'chessground/types'

export interface PromotionMove {
  orig: CgKey;
  dest: CgKey;
}

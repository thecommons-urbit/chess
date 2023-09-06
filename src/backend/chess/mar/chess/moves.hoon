::  take in a chess-game, assemble all moves into a list.
::
/-  chess
/+  chess
=,  format
=,  chess
|_  game=chess-game
++  grab
  |%
  ++  noun  (list [chess-move chess-fen chess-san])
  --
++  grow
  |%
  ++  noun  moves.game
  ++  json
    |^
    %-  frond:enjs
      ['moves' [%a (spun moves.game move-json)]]
    ++  move-json
      |=  [move=[move=chess-move fen=chess-fen san=chess-san] player=chess-side]
      ^-  [^json chess-side]
      =/  squares  (get-squares move.move player)
      :_  (opposite-side player)
      %-  pairs:enjs
      :~  ['san' [%s san.move]]
          ['fen' [%s fen.move]]
          ['from' [%s p.squares]]
          ['to' [%s q.squares]]
      ==
    --
  --
++  grad  %noun
--

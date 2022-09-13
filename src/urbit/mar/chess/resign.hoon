/+  chess
=,  format
|_  upd=chess-action:chess
++  grab
  |%
  ++  noun  chess-action:chess
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    %-  pairs:enjs
    :~  ['gameID' [%s (scot %da game-id.upd)]]
        ['who' [%s (scot %p who.upd)]]
    ==
  --
++  grad  %noun
--

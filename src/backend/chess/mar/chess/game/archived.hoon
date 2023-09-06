/+  chess
=,  format
|_  game=chess-game:chess
++  grab
  |%
  ++  noun  chess-game:chess
  --
++  grow
  |%
  ++  noun  game
  ++  json
    %-  pairs:enjs
    :~  ['gameID' [%s (scot %da game-id.game)]]
        ['event' [%s event.game]]
        ['white' [%s (scot %p white.game)]]
        ['black' [%s (scot %p black.game)]]
        ['result' [%s ?~(result.game '' u.result.game)]]
        ['archived' [%b %.y]]
        ::  default value. updated thru [%x %game @ta %moves ~] scry.
        ['moves' [%a ~]]
    ==
  --
++  grad  %noun
--

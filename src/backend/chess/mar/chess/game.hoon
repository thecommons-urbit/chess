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
    =+  game
    %-  pairs:enjs
    :~  ['gameID' [%s (scot %da game-id)]]
        ['event' [%s event]]
        ['site' [%s site]]
        ['round' [%s (round-string:chess round)]]
        ['white' [%s (player-string:chess white)]]
        ['black' [%s (player-string:chess black)]]
        ['result' [%s ?~(result '' u.result)]]
    ==
  --
++  grad  %noun
--

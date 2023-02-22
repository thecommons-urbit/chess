/-  chess
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
    ::  XX: add the +move-json arm in here for scries
    ::      specific games to work.
    %-  pairs:enjs
    :~  ['gameID' [%s (scot %da game-id.game)]]
        ['event' [%s event.game]]
        ['site' [%s site.game]]
        ['round' [%s (round-string:chess round.game)]]
        ['white' [%s (player-string:chess white.game)]]
        ['black' [%s (player-string:chess black.game)]]
        ['result' [%s ?~(result.game '' u.result.game)]]
        ['moves' [%a ~]]
    ==
  --
++  grad  %noun
--

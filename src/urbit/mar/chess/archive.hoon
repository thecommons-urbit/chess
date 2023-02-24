/-  *chess
/+  chess
=,  format
|_  archive=((mop @dau chess-game) gth)
++  grab
  |%
  ++  noun  ((mop @dau chess-game) gth)
  --
++  grow
  |%
  ++  noun  archive
  ++  json
    |^
    %-  frond:enjs
    :-  'archivedGames'
    :-  %a  (turn (tap:arch-orm archive) archive-json)
    ::
    ++  arch-orm  ((on @dau chess-game) gth)
    ++  archive-json
      |=  archive=[@dau chess-game]
      =/  game  +.archive
      ^-  ^json
      %-  pairs:enjs
      :~  ['gameID' [%s (scot %da game-id.game)]]
          ['event' [%s event.game]]
          ['site' [%s site.game]]
          ['round' [%s (round-string:chess round.game)]]
          ['white' [%s (player-string:chess white.game)]]
          ['black' [%s (player-string:chess black.game)]]
          ['result' [%s ?~(result.game '' u.result.game)]]
          ::  metadata only. no moves.
      ==
    --
  --
++  grad  %noun
--


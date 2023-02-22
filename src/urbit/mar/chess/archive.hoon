/-  *chess
/+  chess
=,  format
::  archive=chess-archive
|_  archive=((mop @dau chess-game) gth)
++  grab
  |%
  ++  noun  ((mop @dau chess-game) gth)
  ::  ++  noun  chess-archive
  --
++  grow
  |%
  ++  noun  archive
  ++  json
    ::  XX: reduce this down to what is found in mar/chess/game
    ::      the moves will be empty, it'll save data.
    ::      also no need for the tap or turn.
    ::
    ::  first: determine if there is a problem with tap and turn
    ::  collapsing mop order.
    ::
    |^
    %-  frond:enjs
    :-  'localArchive'
    :-  %a  (turn (tap:arch-orm archive) archive-json)
    ::
    ::  helps chess-archive mark
    ++  archive-json
      |=  archive=[@dau chess-game]
      =/  game  +.archive
      ::^-  json
      %-  pairs:enjs
      :~  ['gameID' [%s (scot %da game-id.game)]]
          ['event' [%s event.game]]
          ['site' [%s site.game]]
          ['round' [%s (round-string:chess round.game)]]
          ['white' [%s (player-string:chess white.game)]]
          ['black' [%s (player-string:chess black.game)]]
          ['result' [%s ?~(result.game '' u.result.game)]]
          ['moves' [%a (turn moves.game move-json)]]
      ==
    ::
    ::  frontend doesn't recieve a full %chess-move
    ::  it only expects strings for san and fen
    ++  move-json
      |=  move=[chess-move fen=chess-fen san=chess-san]
      ::  ^-  json
      %-  pairs:enjs
      :~  ['san' [%s san.move]]
          ['fen' [%s fen.move]]
      ==
    ++  arch-orm  ((on @dau chess-game) gth)
    --
  --
++  grad  %noun
--


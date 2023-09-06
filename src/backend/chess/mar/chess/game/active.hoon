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
        ['archived' [%b %.n]]
        ::  default values. updated thru [%game @ta %updates ~] sub.
        ['moves' [%a ~]]
        ['position' [%s '']]
        ['gotDrawOffer' [%b %.n]]
        ['sentDrawOffer' [%b %.n]]
        ['drawClaimAvailable' [%b %.n]]
        ['autoClaimSpecialDraws' [%b %.n]]
        ['gotUndoRequest' [%b %.n]]
        ['sentUndoRequest' [%b %.n]]
    ==
  --
++  grad  %noun
--

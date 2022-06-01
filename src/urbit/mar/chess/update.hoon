/+  chess
=,  format
|_  upd=chess-update:chess
++  grab
  |%
  ++  noun  chess-update:chess
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    ?-  -.upd
      %challenge
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'challenge']]
            ['who' [%s (scot %p who.upd)]]
            ['challengerSide' [%s challenger-side.challenge.upd]]
            ['event' [%s event.challenge.upd]]
            ['round' [%s (round-string:chess round.challenge.upd)]]
        ==
      %position
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'position']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['position' [%s position.upd]]
        ==
      %result
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'result']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['result' [%s result.upd]]
        ==
      %draw-offer
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'draw-offer']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %draw-declined
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'draw-declined']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
    ==
  --
++  grad  %noun
--

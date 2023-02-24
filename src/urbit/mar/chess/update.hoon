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
    ::  XX: split %chess-update and /updates into several marks/wires
    ::
    ::      we shouldn't have all this information in one wire.
    ::      as the chess app grows this will become unwieldy,
    ::      subscribers to a wire only want the relevant info.
    ?-  -.upd
      %challenge-sent
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'challenge-sent']]
            ['who' [%s (scot %p who.upd)]]
            ['challengerSide' [%s challenger-side.challenge.upd]]
            ['event' [%s event.challenge.upd]]
            ['round' [%s (round-string:chess round.challenge.upd)]]
        ==
      %challenge-received
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'challenge-received']]
            ['who' [%s (scot %p who.upd)]]
            ['challengerSide' [%s challenger-side.challenge.upd]]
            ['event' [%s event.challenge.upd]]
            ['round' [%s (round-string:chess round.challenge.upd)]]
        ==
      %challenge-resolved
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'challenge-resolved']]
            ['who' [%s (scot %p who.upd)]]
        ==
      %challenge-replied
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'challenge-replied']]
            ['who' [%s (scot %p who.upd)]]
        ==
      %position
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'position']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['move' (pairs:enjs ~[['san' [%s san.upd]] ['fen' [%s position.upd]] ['lastMove' [%a ~[[%s -.last-move.upd] [%s +.last-move.upd]]]]])]
            ['specialDrawAvailable' [%b special-draw-available.upd]]
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
      %special-draw-preference
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'special-draw-preference']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['setting' [%b setting.upd]]
        ==
      %undo-request
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'undo-request']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %undo-declined
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'undo-declined']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %undo-accepted
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'undo-accepted']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['position' [%s position.upd]]
            ['undoMoves' [%n undo-moves.upd]]
        ==
    ==
  --
++  grad  %noun
--

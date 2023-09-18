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
            ['isPractice' [%b practice-game.challenge.upd]]
        ==
      %challenge-received
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'challenge-received']]
            ['who' [%s (scot %p who.upd)]]
            ['challengerSide' [%s challenger-side.challenge.upd]]
            ['event' [%s event.challenge.upd]]
            ['isPractice' [%b practice-game.challenge.upd]]
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
            ['specialDrawAvailable' [%b special-draw-available.upd]]
        ::
            :-  'move'
            %-  pairs:enjs
            :~  ['from' [%s p.move.upd]]
                ['to' [%s q.move.upd]]
                ['san' [%s san.upd]]
                ['fen' [%s position.upd]]
        ==  ==
      %result
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'result']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['result' [%s result.upd]]
        ==
      %offered-draw
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'offered-draw']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %draw-offered
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'draw-offered']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %revoked-draw
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'revoked-draw']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %draw-revoked
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'draw-revoked']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %declined-draw
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'declined-draw']]
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
      %requested-undo
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'requested-undo']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %undo-requested
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'undo-requested']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %revoked-undo
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'revoked-undo']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %undo-revoked
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'undo-revoked']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %declined-undo
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'declined-undo']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %undo-declined
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'undo-declined']]
            ['gameID' [%s (scot %da game-id.upd)]]
        ==
      %accepted-undo
        %-  pairs:enjs
        :~  ['chessUpdate' [%s 'accepted-undo']]
            ['gameID' [%s (scot %da game-id.upd)]]
            ['position' [%s position.upd]]
            ['undoMoves' [%n undo-moves.upd]]
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

/-  chess
=,  format
|_  act=chess-user-action:chess
++  grab
  |%
  ++  noun  chess-user-action:chess
  ++  json
    |=  jon=^json
    %-  chess-user-action:chess
    =/  head  ((ot:dejs ~[[%chess-user-action so:dejs]]) jon)
    ?+  head  ~|  'bad json for chess-action'  !!
      %send-challenge
        :-  %send-challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
            [%challenger-side so:dejs]
            [%event so:dejs]
            [%practice-game bo:dejs]
        ==
      %decline-challenge
        :-  %decline-challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %accept-challenge
        :-  %accept-challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %resign
        :-  %resign
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %offer-draw
        :-  %offer-draw
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %revoke-draw
        :-  %revoke-draw
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %decline-draw
        :-  %decline-draw
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %accept-draw
        :-  %accept-draw
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %claim-special-draw
        :-  %claim-special-draw
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %request-undo
        :-  %request-undo
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %revoke-undo
        :-  %revoke-undo
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %decline-undo
        :-  %decline-undo
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %accept-undo
        :-  %accept-undo
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %make-move
        :-  %make-move
        =+  ^-  [game-id=@dau head=@tas]
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
            [%chess-move so:dejs]
        ==
        ?+  head  ~|  'bad json for chess-move'  !!
          %move
            =/  promotion-parser
              ;~  pose
                (jest 'knight')
                (jest 'bishop')
                (jest 'rook')
                (jest 'queen')
              ==
            :-  game-id
            :-  %move
            %-  |=  [a=* b=* c=* d=* e=*]
                [[a b] [c d] e]
            %.  jon
            %-  ot:dejs
            :~  [%from-file so:dejs]
                [%from-rank (se:dejs %ud)]
                [%to-file so:dejs]
                [%to-rank (se:dejs %ud)]
                [%into (su:dejs-soft promotion-parser)]
            ==
          %castle
            :-  game-id
            :-  %castle
            %.  jon
            %-  ot:dejs
            :~  [%castle-side so:dejs]
            ==
        ==
      %change-special-draw-preference
        :-  %change-special-draw-preference
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
            [%setting bo:dejs]
        ==
    ==
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--

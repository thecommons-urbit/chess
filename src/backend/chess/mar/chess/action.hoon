/-  chess
=,  format
|_  act=chess-action:chess
++  grab
  |%
  ++  noun  chess-action:chess
  ++  json
    |=  jon=^json
    %-  chess-action:chess
    =/  head  ((ot:dejs ~[[%chess-action so:dejs]]) jon)
    ?+  head  ~|  'bad json for chess-action'  !!
      %challenge
        :-  %challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
            [%challenger-side so:dejs]
            [%event so:dejs]
            [%round (su:dejs-soft (more dot dem))]
        ==
      %decline-game
        :-  %decline-game
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %accept-game
        :-  %accept-game
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %game-accepted
        :-  %game-accepted
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
            [%her-side so:dejs]
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
      %draw-offered
        :-  %draw-offered
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
      %draw-declined
        :-  %draw-declined
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
      %undo-requested
        :-  %undo-requested
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
      %undo-declined
        :-  %undo-declined
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
      %undo-accepted
        :-  %undo-accepted
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
      %receive-move
        :-  %receive-move
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
      %end-game
        ::  doesn't matter; we shouldn't be getting this from the frontend
        !!
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

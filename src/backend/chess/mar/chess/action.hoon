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
      %accept-game
        :-  %accept-game
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %decline-game
        :-  %decline-game
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %offer-draw
        :-  %offer-draw
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
      %decline-draw
        :-  %decline-draw
        %.  jon
        %-  ot:dejs
        :~  [%game-id (se:dejs %da)]
        ==
      %move
        :-  %move
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
          %end
            :-  game-id
            :-  %end
            %.  jon
            %-  ot:dejs
            :~  [%result so:dejs]
            ==
        ==
    ==
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--

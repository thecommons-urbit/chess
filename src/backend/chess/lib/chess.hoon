/-  chess
=,  chess
|%
++  opposite-side
  |=  side=chess-side
  ?-  side
    %white  %black
    %black  %white
  ==
++  prev-file
  |=  file=chess-file
  ^-  (unit chess-file)
  ?:  ?=(%a file)
    ~
  =/  prev  (dec file)
  ?>  ?=(chess-file prev)
  `prev
++  next-file
  |=  file=chess-file
  ^-  (unit chess-file)
  ?:  ?=(%h file)
    ~
  =/  next  +(file)
  ?>  ?=(chess-file next)
  `next
++  prev-rank
  |=  rank=chess-rank
  ^-  (unit chess-rank)
  ?:  ?=(%1 rank)
    ~
  =/  prev  (dec rank)
  ?>  ?=(chess-rank prev)
  `prev
++  next-rank
  |=  rank=chess-rank
  ^-  (unit chess-rank)
  ?:  ?=(%8 rank)
    ~
  =/  next  +(rank)
  ?>  ?=(chess-rank next)
  `next
++  prev-file-square
  |=  square=chess-square
  ^-  (unit chess-square)
  =/  pf  (prev-file -.square)
  ?~  pf  ~
  `[u.pf +.square]
++  next-file-square
  |=  square=chess-square
  ^-  (unit chess-square)
  =/  nf  (next-file -.square)
  ?~  nf  ~
  `[u.nf +.square]
++  prev-rank-square
  |=  square=chess-square
  ^-  (unit chess-square)
  =/  pr  (prev-rank +.square)
  ?~  pr  ~
  `[-.square u.pr]
++  next-rank-square
  |=  square=chess-square
  ^-  (unit chess-square)
  =/  nr  (next-rank +.square)
  ?~  nr  ~
  `[-.square u.nr]
::  diagonals reckoned filewise (from left to right)
++  prev-backward-diagonal-square
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-file-square
    next-rank-square
  ==
++  next-backward-diagonal-square
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-file-square
    prev-rank-square
  ==
++  prev-forward-diagonal-square
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-file-square
    prev-rank-square
  ==
++  next-forward-diagonal-square
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-file-square
    next-rank-square
  ==
::  knight moves start from (2 ahead, 1 right)
::  and are counted clockwise
++  knight-1-square  ::  2 forward, 1 right
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-rank-square
    next-rank-square
    next-file-square
  ==
++  knight-2-square  ::  2 right, 1 forward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-file-square
    next-file-square
    next-rank-square
  ==
++  knight-3-square  ::  2 right, 1 backward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-file-square
    next-file-square
    prev-rank-square
  ==
++  knight-4-square  ::  2 backward, 1 right
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-rank-square
    prev-rank-square
    next-file-square
  ==
++  knight-5-square  ::  2 backward, 1 left
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-rank-square
    prev-rank-square
    prev-file-square
  ==
++  knight-6-square  ::  2 left, 1 backward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-file-square
    prev-file-square
    prev-rank-square
  ==
++  knight-7-square  ::  2 left, 1 forward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-file-square
    prev-file-square
    next-rank-square
  ==
++  knight-8-square  ::  2 forward, 1 right
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-rank-square
    next-rank-square
    prev-file-square
  ==
++  knight-squares
  ^-  (list chess-traverser)
  :~  knight-1-square
      knight-2-square
      knight-3-square
      knight-4-square
      knight-5-square
      knight-6-square
      knight-7-square
      knight-8-square
  ==
++  result-string
  |=  result=(unit chess-result)
  ^-  @t
  ?-  result
    ~           '*'
    [~ %'½–½']  '1/2-1/2'
    [~ *]       u.result
  ==
++  square-to-algebraic
  |=  square=chess-square
  ^-  @t
  (cat 3 -.square (scot %ud +.square))
++  fen-piece
  |=  piece=chess-piece
  ^-  @t
  ?-  -.piece
    %white  ?-  +.piece
              %pawn    'P'
              %knight  'N'
              %bishop  'B'
              %rook    'R'
              %queen   'Q'
              %king    'K'
            ==
    %black  ?-  +.piece
              %pawn    'p'
              %knight  'n'
              %bishop  'b'
              %rook    'r'
              %queen   'q'
              %king    'k'
            ==
  ==
++  pgn-piece
  |=  piece=chess-piece
  ^-  @t
  ?-  +.piece
    %pawn    ''
    %knight  'N'
    %bishop  'B'
    %rook    'R'
    %queen   'Q'
    %king    'K'
  ==
++  unicode-piece
  |=  piece=chess-piece
  ^-  @t
  ?-  -.piece
    %white  ?-  +.piece
              %pawn    '♙'
              %knight  '♘'
              %bishop  '♗'
              %rook    '♖'
              %queen   '♕'
              %king    '♔'
            ==
    %black  ?-  +.piece
              %pawn    '♟︎'
              %knight  '♞'
              %bishop  '♝'
              %rook    '♜'
              %queen   '♛'
              %king    '♚'
            ==
  ==
++  render-board
  |_  board=chess-board
  ++  $
    ^-  (list tape)
    =/  rank  `(unit chess-rank)`[~ %1]
    =/  result   `(list tape)`~["  a b c d e f g h "]
    |-  ^-  (list tape)
    ?~  rank
      result
    %=  $
      result  [(rank-to-tape u.rank) result]
      rank    (next-rank u.rank)
    ==
  ++  rank-to-tape
    |=  rank=chess-rank
    ^-  tape
    =/  file    `(unit chess-file)`[~ %h]
    =/  result  "|"
    |-  ^-  tape
    ?~  file
      [(scot %ud rank) result]
    =/  square  (~(get by board) [u.file rank])
    ?~  square
      $(result ['|' ' ' result], file (prev-file u.file))
    $(result ['|' (unicode-piece u.square) result], file (prev-file u.file))
  --
++  position-to-fen
  |_  chess-position
  ++  $
    ^-  @t
    ;:  (cury cat 3)
      board-to-fen
      ' '
      ?-  player-to-move
        %white  'w'
        %black  'b'
      ==
      ' '
      castle-to-fen
      ' '
      ?~  en-passant
        '-'
      (square-to-algebraic u.en-passant)
      ' '
      (scot %ud ply-50-move-rule)
      ' '
      (scot %ud move-number)
    ==
  ++  board-to-fen
    ^-  @t
    =/  rank  `(unit chess-rank)`[~ %8]
    =/  fen   ''
    |-  ^-  @t
    ?~  rank
      (rsh [3 1] fen)
    %=  $
      fen   :((cury cat 3) fen '/' (rank-to-fen u.rank))
      rank  (prev-rank u.rank)
    ==
  ++  rank-to-fen
    |=  rank=chess-rank
    ^-  @t
    =/  file  `(unit chess-file)`[~ %a]
    =/  empty  0
    =/  fen   ''
    |-  ^-  @t
    ?~  file
      ?:  =(empty 0)  fen
      (cat 3 fen (scot %ud empty))
    =/  square  (~(get by board) [u.file rank])
    ?~  square
      $(empty +(empty), file (next-file u.file))
    %=  $
      fen  ?:  =(empty 0)
             (cat 3 fen (fen-piece u.square))
           (cat 3 fen (cat 3 (scot %ud empty) (fen-piece u.square)))
      file  (next-file u.file)
      empty  0
    ==
  ++  castle-to-fen
    ^-  @t
    ?:  ?&  =(white-can-castle %none)
            =(black-can-castle %none)
        ==
      '-'
    %^  cat  3
      ?-  white-can-castle
        %both       'KQ'
        %queenside  'Q'
        %kingside   'K'
        %none       ''
      ==
      ?-  black-can-castle
        %both       'kq'
        %queenside  'q'
        %kingside   'k'
        %none       ''
      ==
  --
++  fen-to-position
  |=  fen=@t
  ~&  %not-implemented  !!
--
|%
++  with-board
  |_  board=chess-board
  ++  white-king
    ^-  chess-square
    ~|  'missing white king'
    =<  p  %-  head
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =([%white %king] piece)
  ++  black-king
    ^-  chess-square
    ~|  'missing black king'
    =<  p  %-  head
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =([%black %king] piece)
  ++  king
    |=  side=chess-side
    ^-  chess-square
    ?-  side
      %white  white-king
      %black  black-king
    ==
  ++  all
    |=  piece=chess-piece
    ^-  (list chess-square)
    %+  murn  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    ^-  (unit chess-square)
    ?:  =(^piece piece)
      `square
    ~
  ++  occupied
    |=  square=chess-square
    ^-  (unit chess-side)
    =/  piece  (~(get by board) square)
    ?~  piece  ~
    [~ -.u.piece]
  ++  raw-move
    |=  [from=chess-square to=chess-square into=(unit chess-promotion)]
    ^-  chess-board
    =/  source-piece  (~(get by board) from)
    ?~  source-piece  !!
    ?~  into
      (~(put by (~(del by board) from)) [to u.source-piece])
    (~(put by (~(del by board) from)) [to [-.u.source-piece u.into]])
  ++  castle
    |=  [side=chess-side castle=?(%queenside %kingside)]
    ^-  chess-board
    ?-  side
      %white
        ?-  castle
          %queenside
            =~  .(board (raw-move [%e %1] [%c %1] ~))
                .(board (raw-move [%a %1] [%d %1] ~))
                board
            ==
          %kingside
            =~  .(board (raw-move [%e %1] [%g %1] ~))
                .(board (raw-move [%h %1] [%f %1] ~))
                board
            ==
        ==
      %black
        ?-  castle
          %queenside
            =~  .(board (raw-move [%e %8] [%c %8] ~))
                .(board (raw-move [%a %8] [%d %8] ~))
                board
            ==
          %kingside
            =~  .(board (raw-move [%e %8] [%g %8] ~))
                .(board (raw-move [%h %8] [%f %8] ~))
                board
            ==
        ==
    ==
  ++  white-pieces
    ^-  (list chess-piece-on-square)
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =(%white -.piece)
  ++  black-pieces
    ^-  (list chess-piece-on-square)
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =(%black -.piece)
  ++  map-by-side
    |*  [side=chess-side gate=chess-transformer]
    ?-  side
      %white  (turn white-pieces gate)
      %black  (turn black-pieces gate)
    ==
  ++  in-check
    |=  side=chess-side
    ^-  ?
    =/  king  (king side)
    =/  threats
    %-  zing
    %+  map-by-side  (opposite-side side)
    |=  piece=chess-piece-on-square
    ^-  (list chess-square)
    ~(threatens with-piece-on-square piece)
    ?~  (find ~[king] threats)
      |
    &
  ++  all-moves
    |=  side=chess-side
    ^-  (list chess-move)
    %+  weld  `(list chess-move)`~[[%castle %queenside] [%castle %kingside]]
    ^-  (list chess-move)
    %-  zing
    %+  map-by-side  side
    |=  piece-on-square=chess-piece-on-square
    ^-  (list chess-move)
    %-  zing
    %+  turn  ~(moves-and-threatens with-piece-on-square piece-on-square)
    |=  to=chess-square
    ^-  (list chess-move)
    ?:  ?&  =(+.piece.piece-on-square %pawn)
            |(=(%1 +.to) =(%8 +.to))
        ==
      :~  [%move square.piece-on-square to `%knight]
          [%move square.piece-on-square to `%bishop]
          [%move square.piece-on-square to `%rook]
          [%move square.piece-on-square to `%queen]
      ==
    ~[[%move square.piece-on-square to ~]]
  ++  with-piece-on-square
    |_  [square=chess-square piece=chess-piece]
    ++  moves
      ^-  (list chess-square)
      ?-  +.piece
        %pawn    pawn-moves
        %knight  knight-moves
        %bishop  bishop-moves
        %rook    rook-moves
        %queen   queen-moves
        %king    king-moves
      ==
    ++  threatens
      ^-  (list chess-square)
      ?-  +.piece
        %pawn    pawn-threatens
        %knight  knight-moves
        %bishop  bishop-moves
        %rook    rook-moves
        %queen   queen-moves
        %king    king-moves
      ==
    ++  moves-and-threatens
      ^-  (list chess-square)
      ?-  +.piece
        %pawn    pawn-both
        %knight  knight-moves
        %bishop  bishop-moves
        %rook    rook-moves
        %queen   queen-moves
        %king    king-moves
      ==
    ++  pawn-moves
      ^-  (list chess-square)
      ?-  -.piece
        %white
          ?:  =(+.square %2)
            ?.  ?=(~ (occupied [-.square %3]))
              ~
            ?.  ?=(~ (occupied [-.square %4]))
              ~[[-.square %3]]
            ~[[-.square %3] [-.square %4]]
          =/  next  (need (next-rank-square square))
          ?.  ?=(~ (occupied next))
            ~
          [next ~]
        %black
          ?:  =(+.square %7)
            ?.  ?=(~ (occupied [-.square %6]))
              ~
            ?.  ?=(~ (occupied [-.square %5]))
              ~[[-.square %6]]
            ~[[-.square %6] [-.square %5]]
          =/  prev  (need (prev-rank-square square))
          ?.  ?=(~ (occupied prev))
            ~
          [prev ~]
      ==
    ++  pawn-threatens  ::  en passant handled elsewhere
      ^-  (list chess-square)
      ?-  -.piece
        %white
          %-  murn
          :_  jump-to
          :~
            prev-backward-diagonal-square
            next-forward-diagonal-square
          ==
        %black
          %-  murn
          :_  jump-to
          :~
            prev-forward-diagonal-square
            next-backward-diagonal-square
          ==
      ==
    ++  pawn-both
      ^-  (list chess-square)
      (weld pawn-moves pawn-threatens)
    ++  knight-moves
      ^-  (list chess-square)
      (murn knight-squares jump-to)
    ++  bishop-moves
      ^-  (list chess-square)
      ;:  weld
        (traverse-by prev-backward-diagonal-square)
        (traverse-by next-backward-diagonal-square)
        (traverse-by prev-forward-diagonal-square)
        (traverse-by next-forward-diagonal-square)
      ==
    ++  rook-moves
      ^-  (list chess-square)
      ;:  weld
        (traverse-by prev-rank-square)
        (traverse-by next-rank-square)
        (traverse-by prev-file-square)
        (traverse-by next-file-square)
      ==
    ++  queen-moves
      ^-  (list chess-square)
      (weld rook-moves bishop-moves)
    ++  king-moves
      ^-  (list chess-square)
      %-  murn
      :_  jump-to
      :~  prev-rank-square
          next-rank-square
          prev-file-square
          next-file-square
          prev-backward-diagonal-square
          next-backward-diagonal-square
          prev-forward-diagonal-square
          next-forward-diagonal-square
      ==
    ++  traverse-by  ::  for rook, bishop, queen moves
      |=  traverser=chess-traverser
      ^-  (list chess-square)
      =/  squares  *(list chess-square)
      =/  current  `(unit chess-square)`(traverser square)
      |-  ^-  (list chess-square)
      ?~  current  squares
      =/  occupant  (occupied u.current)
      ?~  occupant
        %=  $
          squares  [u.current squares]
          current  (traverser u.current)
        ==
      ?:  =(u.occupant (opposite-side -.piece))
        [u.current squares]
      squares
    ++  jump-to  ::  for knights, also used for kings, pawns
      |=  traverser=chess-traverser
      =/  dest  (traverser square)
      ?~  dest  ~
      =/  occupant  (occupied u.dest)
      ?~  occupant  dest
      ?:  =(u.occupant (opposite-side -.piece))
        dest
      ~
    --
  --
++  with-position
  |_  chess-position
  +*  position  +6
  ++  render
    ^-  (list tape)
    %+  weld
    (render-board board)
    :~  "move {(scow %ud move-number)}"
        "{(scow %tas player-to-move)} to move"
        "white can castle {(scow %tas white-can-castle)}"
        "black can castle {(scow %tas black-can-castle)}"
        "en passant target {<en-passant>}"
        "50 move ply {(scow %ud ply-50-move-rule)}"
    ==
  ++  algebraicize
    |=  move=chess-move
    ^-  @t
    ?>  ?|  ?=(%end -.move)
            (legal-move move)
        ==
    ?-  -.move
      %end  +.move
      %castle
        ?-  +.move
          %queenside  'O-O-O'
          %kingside   'O-O'
        ==
      %move
        =/  moving-piece  (~(got by board) from.move)
        =/  target-piece  (~(get by board) to.move)
        =/  is-capture  !?=(~ target-piece)
        =/  possible-froms
          ^-  (list chess-square)
          %+  skim  (~(all with-board board) moving-piece)
          |=  square=chess-square
          (legal-move move(from square))
        =/  disambiguate
          ?:  (gth (lent possible-froms) 1)
            =/  possible-same-file
              ^-  (list chess-square)
              %+  skim  possible-froms
              |=  square=chess-square
              =(-.from.move -.square)
            ?:  (gth (lent possible-same-file) 1)
              =/  possible-same-rank
                ^-  (list chess-square)
                %+  skim  possible-froms
                |=  square=chess-square
                =(+.from.move +.square)
              ?:  (gth (lent possible-same-rank) 1)
                %both
              %rank
            %file
          %none
        =/  applied  (naive-apply move)
        =/  checkmate  ~(in-checkmate with-position applied)
        =/  check  ?:  checkmate  |  ~(in-check with-position applied)
        ?-  +.moving-piece
          %pawn
            %+  rap  3
            :~  ?:(is-capture (cat 3 -.from.move 'x') '')
                -.to.move
                (scot %ud +.to.move)
                ?~  into.move  ''
                  (cat 3 '=' (pgn-piece [%white u.into.move]))
                ?:(check '+' '')
                ?:(checkmate '#' '')
            ==
          ?(%knight %bishop %rook %queen %king)
            %+  rap  3
            :~  (pgn-piece moving-piece)
                ?:(?=(?(%both %file) disambiguate) -.from.move '')
                ?:(?=(?(%both %rank) disambiguate) (scot %ud +.from.move) '')
                ?:(is-capture 'x' '')
                -.to.move
                (scot %ud +.to.move)
                ?:(check '+' '')
                ?:(checkmate '#' '')
            ==
        ==
    ==
  ++  apply-move
    |=  move=chess-move
    ^-  (unit chess-position)
    ?.  (legal-move move)  ~
    `(naive-apply move)
  ++  naive-apply
    |_  move=chess-move
    ++  $
      ^-  chess-position
      ?-  -.move
        %end     position
        %castle
          %=  position
            board             %+  ~(castle with-board board)
                                player-to-move
                                +.move
            player-to-move    (opposite-side player-to-move)
            white-can-castle  ?:  =(player-to-move %white)
                                %none
                              white-can-castle
            black-can-castle  ?:  =(player-to-move %black)
                                %none
                              black-can-castle
            en-passant        ~
            ply-50-move-rule  +(ply-50-move-rule)
            move-number       ?-  player-to-move
                                %white  move-number
                                %black  +(move-number)
                              ==
          ==
        %move
          %=  position
            board
              ?:  ?&  ?=(^ en-passant)
                      =(%pawn +:from-piece)
                      =(u.en-passant to.move)
                  ==
                %-  ~(del by (~(raw-move with-board board) +.move))
                ?-  player-to-move
                  %white  (need (prev-rank-square to.move))
                  %black  (need (next-rank-square to.move))
                ==
              (~(raw-move with-board board) +.move)
            player-to-move    (opposite-side player-to-move)
            white-can-castle  new-white-can-castle
            black-can-castle  new-black-can-castle
            en-passant        en-passant-square
            ply-50-move-rule  ?:  increments-50-move-rule-ply
                                +(ply-50-move-rule)
                              0
            move-number       ?-  player-to-move
                                %white  move-number
                                %black  +(move-number)
                              ==
          ==
      ==
    ++  from-piece
      ^-  chess-piece
      ?>  ?=(%move -.move)
      (~(got by board) from.move)
    ++  double-pawn
      ^-  ?
      ?>  ?=(%move -.move)
      ?&  =(%pawn +:from-piece)
          =(2 (sub (max +.from.move +.to.move) (min +.from.move +.to.move)))
      ==
    ++  en-passant-square
      ^-  (unit chess-square)
      ?>  ?=(%move -.move)
      ?:  double-pawn
        ?-  player-to-move
          %white  (prev-rank-square to.move)
          %black  (next-rank-square to.move)
        ==
      ~
    ++  increments-50-move-rule-ply
      ^-  ?
      ?!  ?|  =(%pawn +:from-piece)
              is-capture
          ==
    ++  is-capture
      ^-  ?
      ?>  ?=(%move -.move)
      ?~  (~(get by board) to.move)
        |
      &
    ++  new-white-can-castle
      ^-  chess-castle
      ?-  white-can-castle
        %none  %none
        %queenside
          ?:  white-loses-queenside
            %none
          %queenside
        %kingside
          ?:  white-loses-kingside
            %none
          %kingside
        %both
          ?:  white-loses-queenside
            new-white-can-castle(white-can-castle %kingside)
          ?:  white-loses-kingside
            new-white-can-castle(white-can-castle %queenside)
          %both
      ==
    ++  new-black-can-castle
      ^-  chess-castle
      ?-  black-can-castle
        %none  %none
        %queenside
          ?:  black-loses-queenside
            %none
          %queenside
        %kingside
          ?:  black-loses-kingside
            %none
          %kingside
        %both
          ?:  black-loses-queenside
            new-black-can-castle(black-can-castle %kingside)
          ?:  black-loses-kingside
            new-black-can-castle(black-can-castle %queenside)
          %both
      ==
    ++  white-loses-queenside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%a %1])
            =(to.move [%a %1])
          =([%white %king] from-piece)
      ==
    ++  white-loses-kingside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%h %1])
            =(to.move [%h %1])
          =([%white %king] from-piece)
      ==
    ++  black-loses-queenside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%a %8])
            =(to.move [%a %8])
          =([%black %king] from-piece)
      ==
    ++  black-loses-kingside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%h %8])
            =(to.move [%h %8])
          =([%black %king] from-piece)
      ==
    --
  ++  in-check
    ^-  ?
    (~(in-check with-board board) player-to-move)
  ++  in-checkmate
    ^-  ?
    &(in-check no-legal-moves)
  ++  in-stalemate
    ^-  ?
    &(!in-check no-legal-moves)
  ++  draw-claimable  ::  XX no threefold repetition yet
    ^-  ?
    (legal-move [%end %'½–½'])
  ++  no-legal-moves
    ^-  ?
    ?=(~ legal-moves)
  ++  legal-moves
    ^-  (list chess-move)
    %+  skim  (~(all-moves with-board board) player-to-move)
    ::  dummy gate to avoid mull-grow
    |=  m=chess-move
    ^-  ?
    (legal-move m)
  ++  legal-move
    |_  move=chess-move
    ++  $
      ^-  ?
      ?-  -.move
        %end
          ?-  +.move
            %'0-1'  =(player-to-move %white)
            %'1-0'  =(player-to-move %black)
            %'½–½'  (gte ply-50-move-rule 100)
          ==
        %castle  castle-move
        %move    normal-move
      ==
    ++  normal-move
      ^-  ?
      ?>  ?=(%move -.move)
      =/  moving-piece  (~(get by board) from.move)
      ?~  moving-piece  |
      ?.  =(player-to-move -.u.moving-piece)  |
      =/  b  ~(. with-board board)
      =/  possible-moves
        ?:  =(%pawn +.u.moving-piece)
          %+  weld
            ~(moves with-piece-on-square:b [from.move u.moving-piece])
            %+  skim
            ~(threatens with-piece-on-square:b [from.move u.moving-piece])
            |=  sq=chess-square
            =/  occupant  (occupied:b sq)
            ?~  occupant
              ?~  en-passant  |
                =(sq u.en-passant)
            =(u.occupant (opposite-side player-to-move))
        ~(moves with-piece-on-square:b [from.move u.moving-piece])
      ?~  (find ~[to.move] possible-moves)
        |
      ?:  (~(in-check with-board (raw-move:b +.move)) player-to-move)
        |
      ?:  &(?=(%pawn +.u.moving-piece) ?=(?(%8 %1) +.to.move))
        ?~  into.move  |  &
      ?~  into.move  &  |
    ++  castle-move
      |^
      ^-  ?
      ?>  ?=(%castle -.move)
      =-  ?&  !(~(in-check with-board board) player-to-move)
              conditions
          ==
      ^=  conditions
      ?-  player-to-move
        %white
          ?-  +.move
            %queenside
              %:  castle-helper
                %white
                %queenside
                [%e %1]
                ~[[%d %1] [%c %1] [%b %1]]
                [%a %1]
              ==
            %kingside
              %:  castle-helper
                %white
                %kingside
                [%e %1]
                ~[[%f %1] [%g %1]]
                [%h %1]
              ==
          ==
        %black
          ?-  +.move
            %queenside
              %:  castle-helper
                %black
                %queenside
                [%e %8]
                ~[[%d %8] [%c %8] [%b %8]]
                [%a %8]
              ==
            %kingside
              %:  castle-helper
                %black
                %kingside
                [%e %8]
                ~[[%f %8] [%g %8]]
                [%h %8]
              ==
          ==
      ==
      ++  castle-helper
        |=  $:  side=chess-side
                castle-side=?(%queenside %kingside)
                king=chess-square
                empty=(list chess-square)
                rook=chess-square
            ==
        ?.  ?&  =(`[side %king] (~(get by board) king))
                %+  levy  empty
                |=  s=chess-square
                ?=  ~  (~(get by board) s)
                =(`[side %rook] (~(get by board) rook))
            ==
          |
        =/  king-once
          (~(raw-move with-board board) king &1.empty ~)
        ?:  (~(in-check with-board king-once) side)
          |
        =/  king-twice
          (~(raw-move with-board board) king &2.empty ~)
        ?:  (~(in-check with-board king-twice) side)
          |
        =/  fully-castled
          (~(castle with-board board) side castle-side)
        ?:  (~(in-check with-board fully-castled) side)
          |
        &
      --
    --
  --
--
|%
++  player-string
  |=  player=chess-player
  ?-  -.player
    %unknown  'Unknown'
    %name     +.player
    %ship     (scot %p +.player)
  ==
++  round-string
  |=  round=(unit (list @))
  ^-  @t
  ?~  round  '?'
  %-  crip  %+  join  '.'
  %+  turn  u.round
  (cury scot %ud)
++  string-to-round
  |=  round=@t
  ^-  (unit (list @))
  ?:  =(round '?')
    ~
  (rush round (more dot dem))
++  play
  |=  game=chess-game
  ^-  (unit chess-position)
  ?.  ?=(~ result.game)
    ~
  =/  position  `(unit chess-position)``*chess-position
  |-  ^-  (unit chess-position)
  ?~  moves.game
    position
  %=  $
    position  %+  biff  position
              |=  p=chess-position
              (~(apply-move with-position p) i.moves.game)
    moves.game  t.moves.game
  ==
++  algebraicize
  |=  game=chess-game
  ^-  (list @t)
  %+  spun  moves.game
  |=  [move=chess-move position=chess-position]
  ^-  [@t chess-position]
  :-  (~(algebraicize with-position position) move)
  (need (~(apply-move with-position position) move))
++  algebraicize-and-number
  |=  game=chess-game
  ^-  (list @t)
  =/  alg-moves  (algebraicize game)
  =/  white  &
  =/  move  1
  =/  moves  *(list @t)
  =/  string  ''
  |-  ^-  (list @t)
  ?~  alg-moves
    ?:  =('' string)
      moves
    (snoc moves string)
  ?:  white
    %=  $
      white      |
      string     (rap 3 ~[(scot %ud move) '. ' i.alg-moves])
      alg-moves  t.alg-moves
    ==
  %=  $
    white      &
    string     ''
    move       +(move)
    moves      (snoc moves (rap 3 ~[string ' ' i.alg-moves]))
    alg-moves  t.alg-moves
  ==
++  to-pgn
    |=  game=chess-game
    ^-  wain
    =/  tags
      %+  turn
      :~  "[UrbitGameID \"{<game-id.game>}\"]"
          "[Event \"{(trip event.game)}\"]"
          "[Site \"{(trip site.game)}\"]"
          "[Date \"{(tail (scow %da date.game))}\"]"
          "[Round \"{(trip (round-string round.game))}\"]"
          "[White \"{(trip (player-string white.game))}\"]"
          "[Black \"{(trip (player-string black.game))}\"]"
          "[Result \"{(trip (result-string result.game))}\"]"
      ==
      crip
    ;:  weld
      tags
      ~['']
      (algebraicize-and-number game)
    ==
++  empty-board
  ^-  chess-board
  ~
++  fools-mate
  ^-  chess-game
  :*  game-id=~2021.2.2..11.01.55..e145.92d5.dbbe.aeaa
      event='?'
      site='?'
      date=*@da
      round=~
      white=[%name 'Fool']
      black=[%name 'Black']
      result=`%'0-1'
  :~
    [%move [%f %2] [%f %3] ~]  [%move [%e %7] [%e %5] ~]  ::  1. f3 e5
    [%move [%g %2] [%g %4] ~]  [%move [%d %8] [%h %4] ~]  ::  2. g4 Qh4#
  ==
  ==
--

/-  chess
=,  chess
::
::  /lib/chess.hoon chapters:
::  %squares
::  %knight-moves
::  %rendering
::  %game-logic
::  XX: create chapters for rest of lib
::
|%
::
::  return info about ranks,
::  files, adjacent squares, etc.
+|  %squares
::
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
::
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
::
::  knight moves start from (2 forward, 1 right)
::  and are counted clockwise
+|  %knight-moves
::
++  knight-1-square
  ::  2 forward, 1 right
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-rank-square
    next-rank-square
    next-file-square
  ==
++  knight-2-square
  ::  2 right, 1 forward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-file-square
    next-file-square
    next-rank-square
  ==
++  knight-3-square
  ::  2 right, 1 backward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-file-square
    next-file-square
    prev-rank-square
  ==
++  knight-4-square
  ::  2 backward, 1 right
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-rank-square
    prev-rank-square
    next-file-square
  ==
++  knight-5-square
  ::  2 backward, 1 left
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-rank-square
    prev-rank-square
    prev-file-square
  ==
++  knight-6-square
  ::  2 left, 1 backward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-file-square
    prev-file-square
    prev-rank-square
  ==
++  knight-7-square
  ::  2 left, 1 forward
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    prev-file-square
    prev-file-square
    next-rank-square
  ==
++  knight-8-square
  ::  2 forward, 1 right
  |=  square=chess-square
  ^-  (unit chess-square)
  %.  square
  ;~  biff
    next-rank-square
    next-rank-square
    prev-file-square
  ==
++  knight-squares
  ::  return list of valid knight-moves
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
::
::  render game information
+|  %rendering
::
::  render game result,
::  which may or may not be null
++  result-string
  |=  result=(unit chess-result)
  ^-  @t
  ?-  result
    ~           '*'
    [~ %'½–½']  '1/2-1/2'
    [~ *]       u.result
  ==
::
::  render chess square [%a %1] as 'a1'
++  square-to-algebraic
  |=  square=chess-square
  ^-  @t
  (cat 3 -.square (scot %ud +.square))
::
::  return a piece's side and type
::  for forsyth-edwards notation
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
::
::  return piece type for
::  portable game notation
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
::
::  return piece's unicode
::  character based on side and type
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
::
::  XX: delete or support this
::
::  render board as list of files and ranks
::  (maybe a leftover from before app had a frontend)
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
      ::  add rank to list result
      result  [(rank-to-tape u.rank) result]
      ::  increment rank
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
::
::  render whole position
::  as forsyth-edwards notation
++  position-to-fen
  |_  chess-position
  ++  simplified
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
    ==
  ++  $
    ^-  @t
    ;:  (cury cat 3)
      simplified
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
::
::  XX: need to implement
::  turn fen into chess-position with checks for valid fen
++  fen-to-position-safe
  |=  fen=chess-fen
  ~&  %not-implemented  !!
::
::  turn fen into chess-position
++  fen-to-position
  |=  fen=chess-fen
  ^-  chess-position
  %+  rash
    fen
  ;~  (glue ace)
      fen-to-board         ::  board
      fen-to-player        ::  player-to-move
      fen-to-white-castle  ::  white-can-castle
      fen-to-black-castle  ::  black-can-castle
      fen-to-en-passant    ::  en-passant
      dem                  ::  ply-50-move-rule
      dem                  ::  move-number
  ==
++  fen-to-board
  %+  cook  board-helper
  %+  more  (just '/')
  ::  XX is this actually slower than alf and fail on invalid char?
  (stun [1 8] (mask "12345678bknpqrBKNPQR"))
++  fen-to-player
  ;~  pose
      (cold %white (just 'w'))
      (cold %black (just 'b'))
  ==
++  fen-to-white-castle
  ;~  pose
      (white-castle-helper hep " -" %none)
      (white-castle-helper (just 'k') " k" %none)
      (white-castle-helper (just 'q') " q" %none)
      (white-castle-helper (jest 'KQ') " " %both)
      (white-castle-helper (just 'K') " " %kingside)
      (white-castle-helper (just 'Q') " " %queenside)
  ==
++  fen-to-black-castle
  ;~  pose
      (cold %none hep)
      (cold %both (jest 'kq'))
      (cold %kingside (just 'k'))
      (cold %queenside (just 'q'))
  ==
++  fen-to-en-passant
  ;~  pose
      (cold ~ hep)
      %+  cook
          some
          ;~  plug
              (cook chess-file (cook term (shim 'a' 'h')))
              (cook chess-rank (cook term (mask "36")))
          ==
  ==
++  board-helper
  |=  brd=(list tape)
  ?>  =((lent brd) 8)
  =/  rank=chess-rank  %8
  =/  file=$?(chess-file %i)  %a
  =/  board  *chess-board
  |-
  ?~  brd
    board
  ?-    file
       %i
     $(brd t.brd, rank (chess-rank (sub rank 1)), file %a)
   ::
       chess-file
     =*  next  (snag (sub file 97) i.brd)
     ?:  (lte next 56)
       $(file (chess-file (add file (sub next 48))))
     ?:  (gte next 97)
       ?+  (term next)  !!
         %b  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%black %bishop]]))
         %k  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%black %king]]))
         %n  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%black %knight]]))
         %p  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%black %pawn]]))
         %q  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%black %queen]]))
         %r  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%black %rook]]))
       ==
     ?+  (term (add next 32))  !!
       %b  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%white %bishop]]))
       %k  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%white %king]]))
       %n  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%white %knight]]))
       %p  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%white %pawn]]))
       %q  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%white %queen]]))
       %r  $(file (chess-file +(file)), board (~(put by board) [[file rank] [%white %rook]]))
  ==
==
++  white-castle-helper
  |*  [rul=rule pre=tape res=chess-castle]
  ;~(pfix rul (funk pre (easy res)))
--
|%
::
::  miscellaneous game logic
+|  %game-logic
::
++  with-board
  |_  board=chess-board
  ::
  ::  scan the board for the white king
  ++  white-king
    ^-  chess-square
    ~|  'missing white king'
    =<  p  %-  head
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =([%white %king] piece)
  ::
  ::  scan the board for the black king
  ++  black-king
    ^-  chess-square
    ~|  'missing black king'
    =<  p  %-  head
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =([%black %king] piece)
  ::
  ::  returns the square the king is on
  ++  king
    |=  side=chess-side
    ^-  chess-square
    ?-  side
      %white  white-king
      %black  black-king
    ==
  ::
  ::  return a list of the squares that contain a given chess-piece
  ++  all
    |=  piece=chess-piece
    ^-  (list chess-square)
    %+  murn  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    ^-  (unit chess-square)
    ?:  =(^piece piece)
      `square
    ~
  ::
  ::  check whether a square is occupied and return the side occupying the square
  ++  occupied
    |=  square=chess-square
    ^-  (unit chess-side)
    =/  piece  (~(get by board) square)
    ?~  piece  ~
    [~ -.u.piece]
  ::
  ::  move a piece by deleting from previous location and adding to new
  ::  location, promoting if needed
  ++  raw-move
    |=  [from=chess-square to=chess-square into=(unit chess-promotion)]
    ^-  chess-board
    =/  source-piece  (~(get by board) from)
    ?~  source-piece  !!
    ?~  into
      (~(put by (~(del by board) from)) [to u.source-piece])
    (~(put by (~(del by board) from)) [to [-.u.source-piece u.into]])
  ::
  ::  move the rook and king accordingly for castling
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
  ::
  ::  produces a list of all white pieces on the board
  ++  white-pieces
    ^-  (list chess-piece-on-square)
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =(%white -.piece)
  ::
  ::  produces a list of all black pieces on the board
  ++  black-pieces
    ^-  (list chess-piece-on-square)
    %+  skim  ~(tap by board)
    |=  [square=chess-square piece=chess-piece]
    =(%black -.piece)
  ::
  ::  applies a gate to the list of white pieces or black pieces
  ++  map-by-side
    |*  [side=chess-side gate=chess-transformer]
    ?-  side
      %white  (turn white-pieces gate)
      %black  (turn black-pieces gate)
    ==
  ::
  ::  returns whether or not a side is in check by making a list
  ::  of pieces being threatened and checking if the king is in that list
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
  ::
  ::  returns a list of all possible moves
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
  ::
  ::  used to check if a piece can move and whether it threatens another piece
  ++  with-piece-on-square
    |_  [square=chess-square piece=chess-piece]
    ::
    ::  list of possible moves for a given piece
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
    ::
    ::  list of possible moves that would threaten another piece
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
    ::
    ::  list of possible moves and moves that would threaten another piece
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
    ::
    ::  list of possible pawn moves
    ++  pawn-moves
      ^-  (list chess-square)
      ?-  -.piece
        %white
          ::  pawns can move 2 spaces on first move
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
          ::  pawns can move 2 spaces on first move
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
    ::
    ::  list of possible pawn moves to capture another piece
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
    ::
    :: list of possible pawn moves and captures
    ++  pawn-both
      ^-  (list chess-square)
      (weld pawn-moves pawn-threatens)
    ::
    ::  list of possible knight moves
    ++  knight-moves
      ^-  (list chess-square)
      (murn knight-squares jump-to)
    ::
    ::  list of possible bishop moves
    ++  bishop-moves
      ^-  (list chess-square)
      ;:  weld
        (traverse-by prev-backward-diagonal-square)
        (traverse-by next-backward-diagonal-square)
        (traverse-by prev-forward-diagonal-square)
        (traverse-by next-forward-diagonal-square)
      ==
    ::
    ::  list of possible rook moves
    ++  rook-moves
      ^-  (list chess-square)
      ;:  weld
        (traverse-by prev-rank-square)
        (traverse-by next-rank-square)
        (traverse-by prev-file-square)
        (traverse-by next-file-square)
      ==
    ::
    ::  list of possible queen moves
    ++  queen-moves
      ^-  (list chess-square)
      (weld rook-moves bishop-moves)
    ::
    ::  list of possible king moves
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
   ::
   ::  list of possible moves by traversing the board in a straight line
   ::  for rook, bishop, and queen moves
    ++  traverse-by
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
    ::
    ::  list of possible moves by jumping directly to square
    ::  for knight, king, and pawn moves
    ++  jump-to
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
::
::  core for performing operations on a chess-position
++  with-position
  |_  chess-position
  +*  position  +6
  ::
  ::  render the state of the board and possible actions as a tape
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
  ::
  ::  produce the result of a move in chess notation as a @t
  ++  algebraicize
    |=  move=chess-move
    ^-  @t
    ?>  (legal-move move)
    ?-  -.move
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
  ::
  ::  apply move if it is a legal move
  ++  apply-move
    |=  move=chess-move
    ^-  (unit chess-position)
    ?.  (legal-move move)  ~
    `(naive-apply move)
  ::
  ::  apply a move without checking if it is legal
  ++  naive-apply
    |_  move=chess-move
    ++  $
      ^-  chess-position
      ?-  -.move
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
    ::
    ::  en passant logic
    ::
    ::  fetch piece that's being moved
    ++  from-piece
      ^-  chess-piece
      ?>  ?=(%move -.move)
      (~(got by board) from.move)
    ::
    ::  determine if a pawn moved 2 spaces
    ++  double-pawn
      ^-  ?
      ?>  ?=(%move -.move)
      ?&  =(%pawn +:from-piece)
          =(2 (sub (max +.from.move +.to.move) (min +.from.move +.to.move)))
      ==
    ::
    ::  return the square a pawn moves over, when it moves 2 spaces
    ++  en-passant-square
      ^-  (unit chess-square)
      ?>  ?=(%move -.move)
      ?:  double-pawn
        ?-  player-to-move
          %white  (prev-rank-square to.move)
          %black  (next-rank-square to.move)
        ==
      ~
    ::
    ::  50 move rule logic
    ::
    ::  50 move rule counter should increment after a move,
    ::  if no pawn has moved and no pieces are captured
    ++  increments-50-move-rule-ply
      ^-  ?
      ?!  ?|  =(%pawn +:from-piece)
              is-capture
          ==
    ::
    ::  check if move captures another piece
    ++  is-capture
      ^-  ?
      ?>  ?=(%move -.move)
      ?~  (~(get by board) to.move)
        |
      &
    ::
    ::  castle logic
    ::
    ::  determine if white can castle after this move
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
    ::
    ::  determine if black can castle after this move
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
    ::
    ::  revoke queenside castle if rook on a1 moves,
    ::  is captured, or the white king moves.
    ++  white-loses-queenside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%a %1])
            =(to.move [%a %1])
          =([%white %king] from-piece)
      ==
    ::
    ::  revoke kingside castle if rook on h1 moves,
    ::  is captured, or the king moves.
    ++  white-loses-kingside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%h %1])
            =(to.move [%h %1])
          =([%white %king] from-piece)
      ==
    ::
    ::  revoke queenside castle if rook on a8 moves,
    ::  is captured, or the black king moves.
    ++  black-loses-queenside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%a %8])
            =(to.move [%a %8])
          =([%black %king] from-piece)
      ==
    ::
    ::  revoke kingside castle if rook on h8 moves,
    ::  is captured, or the black king moves.
    ++  black-loses-kingside
      ^-  ?
      ?>  ?=(%move -.move)
      ?|  =(from.move [%h %8])
            =(to.move [%h %8])
          =([%black %king] from-piece)
      ==
    --
  ::
  ::  check logic
  ::
  ::  determine if the current player’s
  ::  king is threatened
  ++  in-check
    ^-  ?
    (~(in-check with-board board) player-to-move)
  ::
  ::  determine if the current player’s
  ::  king can’t move and is in check
  ++  in-checkmate
    ^-  ?
    &(in-check no-legal-moves)
  ::
  ::  determine if the current player’s
  ::  king can’t move but is not in check
  ++  in-stalemate
    ^-  ?
    &(!in-check no-legal-moves)
  ::
  ::  legal move logic
  ::
  ::  the list of legal moves is empty
  ++  no-legal-moves
    ^-  ?
    ?=(~ legal-moves)
  ::
  ::  skim all possible moves of current player
  ::  produce a list of all legal moves
  ++  legal-moves
    ^-  (list chess-move)
    %+  skim  (~(all-moves with-board board) player-to-move)
    ::  dummy gate to avoid mull-grow
    |=  m=chess-move
    ^-  ?
    (legal-move m)
  ::
  ::  check whether a move is legal and handle resignation
  ++  legal-move
    |_  move=chess-move
    ++  $
      ^-  ?
      ?-  -.move
        %castle  castle-move
        %move    normal-move
      ==
    ::
    ::  check legality of regular move attempts
    ++  normal-move
      ^-  ?
      ?>  ?=(%move -.move)
      =/  moving-piece  (~(get by board) from.move)
      ::  can’t move nothing
      ?~  moving-piece  |
      ::  current player’s side must match the moving pieces side
      ?.  =(player-to-move -.u.moving-piece)  |
      =/  b  ~(. with-board board)
      =/  possible-moves
        ::  check if pawn
        ?:  =(%pawn +.u.moving-piece)
          %+  weld
            ~(moves with-piece-on-square:b [from.move u.moving-piece])
            %+  skim
            ~(threatens with-piece-on-square:b [from.move u.moving-piece])
            ::  check if pawn can move into a square
            |=  sq=chess-square
            =/  occupant  (occupied:b sq)
            ::  if square is empty
            ::  check if the en passant rule applies
            ?~  occupant
              ?~  en-passant  |
                ::  check if square is the en-passant-square
                =(sq u.en-passant)
            ::  check if occupant is an opponent piece
            =(u.occupant (opposite-side player-to-move))
        ::  for non-pawn pieces
        ::  check if move is possible
        ~(moves with-piece-on-square:b [from.move u.moving-piece])
      ::  make sure the destination square is a possible move
      ?~  (find ~[to.move] possible-moves)
        |
      ::  see if the current player will be in check after the move is complete
      ::    you can’t put yourself in check
      ?:  (~(in-check with-board (raw-move:b +.move)) player-to-move)
        |
      ::  permit pawn promotion if a pawn reaches the 1 or 8 rank
      ?:  &(?=(%pawn +.u.moving-piece) ?=(?(%8 %1) +.to.move))
        ?~  into.move  |  &
      ?~  into.move  &  |
    ::
    ::  check legality of castling attempts
    ++  castle-move
      |^
      ^-  ?
      ?>  ?=(%castle -.move)
      ::  can’t castle when in check
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
      ::
      ::  helper gate to verify generalized castle attempts
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
        ::  king can’t pass through a threatened square during castle
        =/  king-once
          (~(raw-move with-board board) king &1.empty ~)
        ?:  (~(in-check with-board king-once) side)
          |
        =/  king-twice
          (~(raw-move with-board board) king &2.empty ~)
        ?:  (~(in-check with-board king-twice) side)
          |
        ::  can’t castle twice
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
::
::  produce @t version of player name
++  player-string
  |=  player=chess-player
  ?-  -.player
    %unknown  'Unknown'
    %name     +.player
    %ship     (scot %p +.player)
  ==
::
::  produce @t version of the round number
::  ex: '1.2.3.4.5'
++  round-string
  |=  round=(unit (list @))
  ^-  @t
  ?~  round  '?'
  %-  crip  %+  join  '.'
  %+  turn  u.round
  (cury scot %ud)
::
::  convert a sting of rounds back into a list
++  string-to-round
  |=  round=@t
  ^-  (unit (list @))
  ?:  =(round '?')
    ~
  (rush round (more dot dem))
::
::  play out all moves of an in-complete game
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
              (~(apply-move with-position p) -.i.moves.game)
    moves.game  t.moves.game
  ==
::
::  pgn conversion logic
::
::  convert the moves listed in a game into
::  chess notation as a list of @t
++  algebraicize
  |=  game=chess-game
  ^-  (list @t)
  %+  spun  moves.game
  |=  [move=[chess-move chess-fen chess-san] position=chess-position]
  ^-  [@t chess-position]
  :-  (~(algebraicize with-position position) -.move)
  (need (~(apply-move with-position position) -.move))
::
::  keep count of every move
::  add the move number to chess notation
::  XX: should we remove this if we're not only not using
::      it, but won't use it due to undo functionality?
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
::
::  produce portable game notation
::  add a sting of every move in chess notation
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
::
::  not used in the code,
::  but useful for testing.
++  empty-board
  ^-  chess-board
  ~
::
::  a test game
::  a game that ends in four moves with black side winning
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
    ::  1. f3 e5
     [[%move [%f %2] [%f %3] ~] 'rnbqkbnr/pppppppp/8/8/8/5P2/PPPPP1PP/RNBQKBNR b KQkq - 0 1' 'f3']
     [[%move [%e %7] [%e %5] ~] 'rnbqkbnr/pppp1ppp/8/4p3/8/5P2/PPPPP1PP/RNBQKBNR w KQkq e6 0 1' 'e5']
     ::  2. g4 Qh4#
     [[%move [%g %2] [%g %4] ~] 'rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 1' 'g4']
     [[%move [%d %8] [%h %4] ~] 'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 0 1' 'Qh4#']
  ==
  ==
--

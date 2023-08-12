|%
+$  game-id       @dau
+$  chess-player  ship
::
::  a chess player is one of two sides
+$  chess-side
  $~  %white
  $?  %white
      %black
  ==
::
::  a chess piece is one of six types
+$  chess-piece-type
  $~  %pawn
  $?  %pawn
      %knight
      %bishop
      %rook
      %queen
      %king
  ==
::
::  a pawn can be promoted to...
+$  chess-promotion
  $~  %queen
  $?  %knight
      %bishop
      %rook
      %queen
  ==
::
::  a chess piece is a cell of its side and type
+$  chess-piece
  $~  [%white %pawn]
  $:  chess-side
      chess-piece-type
  ==
::
::  a chessboard has eight rows called ranks, numbered %1 to %8
+$  chess-rank
  $~  %1
  ?(%1 %2 %3 %4 %5 %6 %7 %8)
::
::  a chessboard has eight columns called files, labelled %a to %h
+$  chess-file
  $~  %a
  ?(%a %b %c %d %e %f %g %h)
::
::  a chess square is a cell of file and rank
+$  chess-square
  $~  [%a %1]
  [chess-file chess-rank]
::
::  chess-traverser is a gate which takes a chess-square
::  as input, and could return a chess-square or null.
::  this helps prevent chess-pieces moving off the board.
+$  chess-traverser
  $-(chess-square (unit chess-square))
::
::  XX: Remove chess-transformer from here and /lib/chess.hoon
+$  chess-transformer
  $-(chess-piece-on-square *)
::
::  XX: `chess-board` should probably be `chessboard`
::
::  the chessboard state is a map of square to piece.
::  this represents what pieces are still in play, and
::  where they are on the board
+$  chess-board
::
::  the chessboard's default state
  $~
    %-  my
    :~
      [[%a %1] [%white %rook]]
      [[%b %1] [%white %knight]]
      [[%c %1] [%white %bishop]]
      [[%d %1] [%white %queen]]
      [[%e %1] [%white %king]]
      [[%f %1] [%white %bishop]]
      [[%g %1] [%white %knight]]
      [[%h %1] [%white %rook]]
      [[%a %2] [%white %pawn]]
      [[%b %2] [%white %pawn]]
      [[%c %2] [%white %pawn]]
      [[%d %2] [%white %pawn]]
      [[%e %2] [%white %pawn]]
      [[%f %2] [%white %pawn]]
      [[%g %2] [%white %pawn]]
      [[%h %2] [%white %pawn]]
      [[%a %8] [%black %rook]]
      [[%b %8] [%black %knight]]
      [[%c %8] [%black %bishop]]
      [[%d %8] [%black %queen]]
      [[%e %8] [%black %king]]
      [[%f %8] [%black %bishop]]
      [[%g %8] [%black %knight]]
      [[%h %8] [%black %rook]]
      [[%a %7] [%black %pawn]]
      [[%b %7] [%black %pawn]]
      [[%c %7] [%black %pawn]]
      [[%d %7] [%black %pawn]]
      [[%e %7] [%black %pawn]]
      [[%f %7] [%black %pawn]]
      [[%g %7] [%black %pawn]]
      [[%h %7] [%black %pawn]]
    ==
  (map chess-square chess-piece)
::
::  chess-piece-on-square helps us deal with
::  key-value pairs from chess-board
+$  chess-piece-on-square
  [square=chess-square piece=chess-piece]
::
::  chess-castle returns the castle options
::  available to a player: kingside,
::  queenside, both, or neither
+$  chess-castle
  $~  %both
  $?  %both
      %queenside
      %kingside
      %none
  ==
::
::  the current state of the game
+$  chess-position
  $~  [*chess-board %white %both %both ~ 0 1]
  $:
  ::  current state of the chessboard
    board=chess-board
  ::  whose turn is it?
    player-to-move=chess-side
  ::  white castle options
    white-can-castle=chess-castle
  ::  black castle options
    black-can-castle=chess-castle
  ::  position of en passant pawn, if one exists
    en-passant=(unit chess-square)
  ::  how close are we to invoking the 50-move rule?
    ply-50-move-rule=@
  ::  how many moves have there been?
    move-number=@
  ==
::
::  the game's result is a win, loss, or draw
::  to be recorded in chess-game
+$  chess-result
  $~  %'½–½'
  $?  %'1-0'
      %'0-1'
      %'½–½'
  ==
::
::  a chess-move is one of three types:
::  a regular move from one square to another,
::  potentially with a promotion;
::  a queen- or king-side castle;
::  or a finishing move with a result
+$  chess-move
  $%  [%move from=chess-square to=chess-square into=(unit chess-promotion)]
      [%castle ?(%queenside %kingside)]
  ==
::
::  chess-fen is a FEN position
+$  chess-fen  @t
::
::  chess-san is one move's SAN
+$  chess-san  @t
::
::  chess-game stores metadata for a game
::  represented by chess-position
+$  chess-game
  ::  default values
  $~  :*  game-id=*game-id
          date=*@da
          white=*chess-player
          black=*chess-player
          result=~
          moves=~
      ==
  $:
  ::  type definition
  ::  ~1996.2.16..10.00.00..0000
    =game-id
  ::  ~1996.2.16
    date=@da
  ::  [%name 'Deep Blue']
    white=chess-player
  ::  [%name 'Garry Kasparov']
    black=chess-player
  ::  %'0-1'
    result=(unit chess-result)
  ::  a list of this round's moves, with
  ::  corresponding fen and san for each move
    moves=(list [chess-move chess-fen chess-san])
  ==
::
::  a challenge is the challenger's side,
::  a description, and (optionally) this round's number
+$  chess-challenge
  $~  :*  challenger-side=%random
          event='Casual Game'
      ==
  $:
    challenger-side=?(chess-side %random)
    event=@t
  ==
::
::  chess-action defines the acceptable
::  values of a %chess-action poke
+$  chess-action
  $%  [%challenge who=ship challenge=chess-challenge]
      [%decline-game who=ship]
      [%accept-game who=ship]
      [%game-accepted =game-id her-side=chess-side]
      [%resign =game-id]
      [%offer-draw =game-id]
      [%draw-offered =game-id]
      [%decline-draw =game-id]
      [%draw-declined =game-id]
      [%accept-draw =game-id]
      [%claim-special-draw =game-id]
      [%request-undo =game-id]
      [%undo-requested =game-id]
      [%decline-undo =game-id]
      [%undo-declined =game-id]
      [%accept-undo =game-id]
      [%undo-accepted =game-id]
      [%make-move =game-id move=chess-move]
      [%receive-move =game-id move=chess-move]
      [%end-game =game-id result=chess-result move=(unit chess-move)]
      [%change-special-draw-preference =game-id setting=?]
  ==
::
::  chess-update defines the possible values that a
::  subscriber may receive as a %fact from the chess agent
+$  chess-update
  $%  [%challenge-sent who=ship challenge=chess-challenge]
      [%challenge-received who=ship challenge=chess-challenge]
      [%challenge-resolved who=ship]
      [%challenge-replied who=ship]
      [%draw-offer =game-id]
      [%draw-declined =game-id]
      [%undo-declined =game-id]
      [%undo-accepted =game-id position=@t undo-moves=@ta]
      [%undo-request =game-id]
      [%result =game-id result=chess-result]
      [%special-draw-preference =game-id setting=?]
  ::
      $:  %position
          =game-id
          move=(pair @t @t)
          position=@t
          san=@t
          special-draw-available=?
  ==  ==
::
::  @uvH is an unsigned, 256-bit, base-32 integer
+$  chess-rng
  $%  [%commit p=@uvH]
      [%reveal p=@uvH]
  ==
::
+$  chess-commitment
  $:  our-num=@uvH
      our-hash=@uvH
      her-num=(unit @uvH)
      her-hash=(unit @uvH)
      revealed=_|
  ==
::
+$  chess-game-result
  $:  =game-id
      result=chess-result
      move=(unit chess-move)
  ==
--

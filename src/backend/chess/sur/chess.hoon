|%
::
::  types for identification
+|  %id
::
::  @dau is a custom type that nests under @da, used as a unique ID for the
::  game, shared between both players
::
::  @dau is now.bowl at time when the poke accepting the game is processed, but
::  with the lowest 6 bytes filled with random data from eny.bowl (to avoid
::  possible collisions caused by processing multiple games as part of one
::  event)
+$  game-id  @dau
::
::  types most basic of chess concepts
+|  %basic
::
::  only urbit users may play %chess
+$  chess-player  ship
::
::  a chess player plays one of two sides
+$  chess-side
  $~  %white
  $?  %white
      %black
  ==
::
::  types for chess pieces
+|  %piece
::
::  a chess piece has one of six types
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
::  a chess piece is a combination of its side and type
+$  chess-piece
  $~  [%white %pawn]
  $:  chess-side
      chess-piece-type
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
::  types for the chess board
+|  %board
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
::  a chessboard maps squares to pieces (though the opposite relationship is
::  more intuitive when thinking about a physical chessboard)
::
::  this represents what pieces are still in play, and where they are on the
::  board
+$  chess-board
  ::  the chess-board default state
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
::  a helper type to deal with key-value pairs from chess-board
+$  chess-piece-on-square
  [square=chess-square piece=chess-piece]
::
::  types dealing with chess piece movement on the board
+|  %movement
::
::  chess-castle returns the castle options available to a player:
::    kingside
::    queenside
::    both
::    neither
+$  chess-castle
  $~  %both
  $?  %both
      %queenside
      %kingside
      %none
  ==
::
::  a chess piece may move from one square to another, or the king can castle
+$  chess-move
  $%  [%move from=chess-square to=chess-square into=(unit chess-promotion)]
      [%castle ?(%queenside %kingside)]
  ==
::
::  helper for gates moving pieces from one square to another
+$  chess-traverser
  $-(chess-square (unit chess-square))
::
::  helper for generic piece transformations
+$  chess-transformer
  $-(chess-piece-on-square *)
::
::  types for challenging another player
+|  %challenge
::
::  a challenge is the side as which the challenger would like to play and
::  a message or description for the game to be played
+$  chess-challenge
  $~  :*  challenger-side=%random
          event=''
      ==
  $:
    challenger-side=?(chess-side %random)
    event=@t
  ==
::
::  message type for the handshake used to randomly assign sides
::
::  a user can commit to having picked a random number by sharing its hash, or
::  he can reveal the random number he picked
::
::  @uvH is an unsigned, 256-bit, base-32 integer
+$  chess-rng
  $%  [%commit p=@uvH]
      [%reveal p=@uvH]
  ==
::
::  state of the handshake used to randomly assign sides
+$  chess-commitment
  $:  our-num=@uvH
      our-hash=@uvH
      her-num=(unit @uvH)
      her-hash=(unit @uvH)
      revealed=_|
  ==
::
::  types for rendering chess moves
+|  %rendering
::
::  chess-fen is a FEN position
+$  chess-fen  @t
::
::  chess-san is one move's SAN
+$  chess-san  @t
::
::  types for representing a game played between two players
+|  %game
::
::  the current state of each player's position on the board
+$  chess-position
  $~  [*chess-board %white %both %both ~ 0 1]
  $:
    ::  current state of the chessboard
    board=chess-board
    ::  whose turn is it?
    player-to-move=chess-side
    ::  white player's castle options
    white-can-castle=chess-castle
    ::  black player's castle options
    black-can-castle=chess-castle
    ::  position of en passant pawn, if one exists
    en-passant=(unit chess-square)
    ::  how close are we to invoking the 50-move rule?
    ply-50-move-rule=@
    ::  how many moves have there been?
    move-number=@
  ==
::
::  games can result in a win, loss, or draw
::
::  notation is "[points earned by white]-[points earned by black]"
+$  chess-result
  $~  %'½–½'
  $?  %'1-0'
      %'0-1'
      %'½–½'
  ==
::
::  metadata for a chess position
+$  chess-game
  ::  default values
  $~  :*  game-id=*game-id
          event=''
          date=*@da
          white=*chess-player
          black=*chess-player
          result=~
          moves=~
      ==
  $:
    ::  unique identifier for game
    ::    e.g. ~1996.2.16..10.00.00..0000
    =game-id
    ::  description of game
    ::    e.g. 'Kasparov vs. Deep Blue: Game 5
    event=@t
    ::  date game was played
    ::    e.g. ~1996.2.16
    date=@da
    ::  who played white
    ::    e.g. Deep Blue
    white=chess-player
    ::  who played black
    ::    e.g. Gary Kasparov
    black=chess-player
    ::  result of match (if it's over)
    ::    e.g. 0-1
    result=(unit chess-result)
    ::  a list of the moves played, in Urbit, FEN, and SAN notation
    ::
    ::  XX: we should probably have a named type
    ::      for [chess-move chess-fen chess-san].
    ::      and possibly a type for a list of it.
    moves=(list [chess-move chess-fen chess-san])
  ==
::
::  message type for a game concluding: which game ended, how, and why
+$  chess-game-result
  $:  =game-id
      result=chess-result
      move=(unit chess-move)
  ==
::
::  types for controlling game state inside Urbit
+|  %control
::
::  actions users may send to the agent to update game state
+$  chess-user-action
  $%  [%send-challenge who=ship challenge=chess-challenge]
      [%decline-challenge who=ship]
      [%accept-challenge who=ship]
      [%resign =game-id]
      [%offer-draw =game-id]
      [%revoke-draw =game-id]
      [%decline-draw =game-id]
      [%accept-draw =game-id]
      [%claim-special-draw =game-id]
      [%request-undo =game-id]
      [%revoke-undo =game-id]
      [%decline-undo =game-id]
      [%accept-undo =game-id]
      [%make-move =game-id move=chess-move]
      [%change-special-draw-preference =game-id setting=?]
  ==
::
::  actions agents may send to other agents to update game state
+$  chess-agent-action
  $%  [%challenge-received challenge=chess-challenge]
      [%challenge-declined ~]
      [%challenge-accepted =game-id her-side=chess-side]
      [%draw-offered =game-id]
      [%draw-revoked =game-id]
      [%draw-declined =game-id]
      [%undo-requested =game-id]
      [%undo-revoked =game-id]
      [%undo-declined =game-id]
      [%undo-accepted =game-id]
      [%receive-move =game-id move=chess-move]
      [%end-game =game-id result=chess-result move=(unit chess-move)]
  ==
::
::  updates to game state agent may send to observers
+$  chess-update
  $%  [%challenge-sent who=ship challenge=chess-challenge]
      [%challenge-received who=ship challenge=chess-challenge]
      [%challenge-resolved who=ship]
      [%challenge-replied who=ship]
      [%offered-draw =game-id]
      [%draw-offered =game-id]
      [%revoked-draw =game-id]
      [%draw-revoked =game-id]
      [%declined-draw =game-id]
      [%draw-declined =game-id]
      [%requested-undo =game-id]
      [%undo-requested =game-id]
      [%revoked-undo =game-id]
      [%undo-revoked =game-id]
      [%declined-undo =game-id]
      [%undo-declined =game-id]
      [%accepted-undo =game-id position=@t undo-moves=@ta]
      [%undo-accepted =game-id position=@t undo-moves=@ta]
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
--

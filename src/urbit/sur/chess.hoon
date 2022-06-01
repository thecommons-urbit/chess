|%
+$  chess-side
  $~  %white
  $?  %white
      %black
  ==
+$  chess-piece-type
  $~  %pawn
  $?  %pawn
      %knight
      %bishop
      %rook
      %queen
      %king
  ==
+$  chess-promotion
  $~  %queen
  $?  %knight
      %bishop
      %rook
      %queen
  ==
+$  chess-piece
  $~  [%white %pawn]
  $:  chess-side
      chess-piece-type
  ==
+$  chess-rank
  $~  %1
  ?(%1 %2 %3 %4 %5 %6 %7 %8)
+$  chess-file
  $~  %a
  ?(%a %b %c %d %e %f %g %h)
+$  chess-square
  $~  [%a %1]
  [chess-file chess-rank]
+$  chess-piece-on-square
  [square=chess-square piece=chess-piece]
+$  chess-traverser
  $-(chess-square (unit chess-square))
+$  chess-transformer
  $-(chess-piece-on-square *)
+$  chess-board
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
+$  chess-castle
  $~  %both
  $?  %both
      %queenside
      %kingside
      %none
  ==
+$  chess-position
  $~  [*chess-board %white %both %both ~ 0 1]
  $:
    board=chess-board
    player-to-move=chess-side
    white-can-castle=chess-castle
    black-can-castle=chess-castle
    en-passant=(unit chess-square)
    ply-50-move-rule=@
    move-number=@
  ==
+$  chess-player
  $~  [%unknown ~]
  $%  [%name @t]
      [%ship @p]
      [%unknown ~]
  ==
+$  chess-result
  $~  %'½–½'
  $?  %'1-0'
      %'0-1'
      %'½–½'
  ==
+$  chess-move
  $~  [%end %'½–½']
  $%  [%move from=chess-square to=chess-square into=(unit chess-promotion)]
      [%castle ?(%queenside %kingside)]
      [%end chess-result]
  ==
+$  chess-game
  $~  :*  game-id=*@dau
          event='?'
          site='Urbit Chess'
          date=*@da
          round=~
          white=*chess-player
          black=*chess-player
          result=~
          moves=~
      ==
  $:
    game-id=@dau
    event=@t
    site=@t
    date=@da
    round=(unit (list @))  ::  ~ if unknown, `~ if inappropriate
    white=chess-player
    black=chess-player
    result=(unit chess-result)
    moves=(list chess-move)
  ==
+$  chess-challenge
  $~  :*  challenger-side=%random
          event='Casual Game'
          round=`~
      ==
  $:
    challenger-side=?(chess-side %random)
    event=@t
    round=(unit (list @))
  ==
+$  chess-action
  $%  [%challenge who=ship challenge=chess-challenge]
      [%accept-game who=ship]
      [%decline-game who=ship]
      [%offer-draw game-id=@dau]
      [%accept-draw game-id=@dau]
      [%decline-draw game-id=@dau]
      [%move game-id=@dau move=chess-move]
  ==
+$  chess-update
  $%  [%challenge who=ship challenge=chess-challenge]
      [%position game-id=@dau position=@t]
      [%result game-id=@dau result=chess-result]
      [%draw-offer game-id=@dau]
      [%draw-declined game-id=@dau]
  ==
+$  chess-rng
  $%  [%commit p=@uvH]
      [%reveal p=@uvH]
  ==
+$  chess-commitment
  $:  our-num=@uvH
      our-hash=@uvH
      her-num=(unit @uvH)
      her-hash=(unit @uvH)
      revealed=_|
  ==
--

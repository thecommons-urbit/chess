/-  *chess
|%
+$  active-game-state-0
  $:  game=chess-game-0
      position=chess-position
      ready=?
      sent-draw-offer=?
      got-draw-offer=?
  ==
+$  state-0
  $:  %0
      games=(map @dau active-game-state-0)
      archive=(map @dau chess-game-0)
      challenges-sent=(map ship chess-challenge)
      challenges-received=(map ship chess-challenge)
      rng-state=(map ship chess-commitment)
  ==
+$  chess-move-0
   $~  [%end %'½–½']
   $%  [%move from=chess-square to=chess-square into=(unit chess-promotion)]
       [%castle ?(%queenside %kingside)]
       [%end chess-result]
   ==
+$  chess-game-0
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
    moves=(list chess-move-0)
  ==
+$  chess-action-0
  $%  [%challenge who=ship challenge=chess-challenge]
      [%accept-game who=ship]
      [%decline-game who=ship]
      [%offer-draw game-id=@dau]
      [%accept-draw game-id=@dau]
      [%decline-draw game-id=@dau]
      [%move game-id=@dau move=chess-move-0]
  ==
+$  chess-update-0
  $%  [%challenge who=ship challenge=chess-challenge]
      [%position game-id=@dau position=@t]
      [%result game-id=@dau result=chess-result]
      [%draw-offer game-id=@dau]
      [%draw-declined game-id=@dau]
  ==
--

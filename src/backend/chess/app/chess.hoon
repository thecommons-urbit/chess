::  chess: fully decentralized, peer-to-peer chess app for urbit
::
::  XX: need frontend notifications for errors / nacks
::  XX: need frontend notifications for attempting to challenge user more than once
::
::  import libraries and expose namespace
/-  *historic
/+  *chess, dbug, default-agent, pals
::
::  define state structures
|%
+$  versioned-state
  $%  state-0
      state-1
  ==
+$  active-game-state
  $:  game=chess-game
      position=chess-position
      move-in-progress=(unit chess-move)
      fen-repetition=(map @t @ud)
      special-draw-available=?
      auto-claim-special-draws=?
      sent-draw-offer=?
      got-draw-offer=?
      sent-undo-request=?
      got-undo-request=?
      opponent=ship
  ==
+$  state-1
  $:  %1
      games=(map game-id active-game-state)
      archive=(map game-id chess-game)
      challenges-sent=(map ship chess-challenge)
      challenges-received=(map ship chess-challenge)
      rng-state=(map ship chess-commitment)
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-1
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %|) bowl)
++  on-init
  on-init:default
++  on-save
  !>(state)
++  on-load
  |=  old-state-vase=vase
  ^-  (quip card _this)
  =/  old-state  !<(versioned-state old-state-vase)
  ?-  -.old-state
    %1  [~ this(state old-state)]
    %0  [~ this(state *state-1)]
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
    ::
    ::  pokes managing active game state and challenges
    %chess-action
      ::  only allow chess actions from our ship or our moons
      ?>  =(our.bowl src.bowl)
      =/  action  !<(chess-action vase)
      ?-  -.action
        ::  manage new outgoing challenges
        %challenge
          ::  only allow one active challenge per ship
          ?:  (~(has by challenges-sent) who.action)
            :_  this
            =/  err
              "already challenged {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::
          ::  send new challenge
          :-  :~  :*  %pass  /poke/challenge/send  %agent  [who.action %chess]
                      %poke  %chess-challenge  !>(challenge.action)
                  ==
              ==
          ::  add to list of outgoing challenges
          %=  this
            challenges-sent  (~(put by challenges-sent) +.action)
          ==
        %decline-game
          =/  challenge  (~(get by challenges-received) who.action)
          ::  check if challenge exists
          ?~  challenge
            :_  this
            =/  err
              "no challenge to decline from {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  tell our challenger we decline
          :-  :~  :*  %pass  /poke/challenge/reply  %agent  [who.action %chess]
                      %poke  %chess-decline-challenge  !>(~)
              ==  ==
          %=  this
            ::  remove our challenger from challenges-received
            challenges-received  (~(del by challenges-received) who.action)
          ==
        %accept-game
          =/  challenge  (~(get by challenges-received) who.action)
          ::  check if challenge exists
          ?~  challenge
            :_  this
            =/  err  "no challenge to accept from {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  step 1 of assigning random sides
          ?:  ?=(%random challenger-side.u.challenge)
            =/  our-num  (shaf now.bowl eny.bowl)
            =/  our-hash  (shaf %chess-rng our-num)
            :-  :~  :*  %pass  /poke/rng/commit  %agent  [who.action %chess]
                        %poke  %chess-rng  !>([%commit our-hash])
                ==  ==
            %=  this
              rng-state  (~(put by rng-state) who.action [our-num our-hash ~ ~ |])
            ==
          =/  our-side
            ?:  ?=(%white challenger-side.u.challenge)
              %black
            %white
          ::  create a unique game id
          =/  game-id
            (mix now.bowl (end [3 6] eny.bowl))
          :_  this
          ::  attempt to accept game
          ::  handle our end on ack
          :~  :*  %pass
                  /poke/game/(scot %da game-id)/init
                  %agent
                  [who.action %chess]
                  %poke
                  [%chess-action !>([%game-accepted game-id our-side])]
          ==  ==
        %game-accepted
          =/  challenge  (~(get by challenges-sent) src.bowl)
          ?~  challenge
            :_  this
            =/  err
              "{<our.bowl>} hasn't challenged you"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ?:  =(her-side.action challenger-side.u.challenge)
            :_  this
            =/  err
              "{<our.bowl>} expects to be {<her-side.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  assign ships to white and black
          =+  ^=  [white-player black-player]
              ?:  ?=(%white her-side.action)
                [src.bowl our.bowl]
              [our.bowl src.bowl]
          ::  initialize new game
          =/  new-game
            ^-  chess-game
            :*  game-id.action
                (yule [d:(yell game-id.action) 0 0 0 ~])
                white-player
                black-player
                ~
                ~
            ==
          :-
            ::  add our new game to the list of active games
            :~  :*  %give  %fact  ~[/active-games]
                    %chess-game  !>(new-game)
                ==
                ::  tell our frontend we accepted the challenge
                :*  %give  %fact   ~[/challenges]
                    %chess-update  !>([%challenge-resolved src.bowl])
                ==
            ==
          %=  this
            ::  remove our challenge from challenges-sent
            challenges-sent  (~(del by challenges-sent) src.bowl)
            ::  put our new game into the map of games
            games  (~(put by games) game-id.action [new-game *chess-position ~ *(map @t @ud) | | | | | | src.bowl])
          ==
        %resign
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  result
            ?:  =(our.bowl +.white.game.u.game-state)
              %'0-1'
            %'1-0'
          :_  this
          ::  resign
          ::  handle our end on ack
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[result]
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%end-game game-id.action result ~])]
          ==  ==
        %offer-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  send draw offer to opponent
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/offer-draw
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%draw-offered game-id.action])]
          ==  ==
        %draw-offered
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update  !>([%draw-offer game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(got-draw-offer &))
          ==
        %decline-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open draw offer
          ?.  got-draw-offer.u.game-state
            :_  this
            =/  err  "no draw offer to decline for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            ::  decline draw offer
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/decline-draw
                    %agent  [opponent.u.game-state %chess]
                    %poke
                    [%chess-action !>([%draw-declined game-id.action])]
                ==
                ::  we don't care if opponent acks/nacks
                :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update  !>([%draw-declined game-id])
            ==  ==
          %=  this
            ::  record that draw offer is gone
            games  (~(put by games) game-id.action u.game-state(got-draw-offer |))
          ==
        %draw-declined
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for sent draw offer
          ?.  sent-draw-offer.u.game-state
            :_  this
            =/  err  "{<our.bowl>} did not send draw offer for {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update  !>([%draw-declined game-id.action])
            ==  ==
          %=  this
            ::  record that draw offer is gone
            games  (~(put by games) game-id.action u.game-state(sent-draw-offer |))
          ==
        %accept-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open draw offer
          ?.  got-draw-offer.u.game-state
            :_  this
            =/  err  "no draw offer to accept for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  tell opponent we accept the draw
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[%'½–½']
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%end-game game-id.action %'½–½' ~])]
          ==  ==
        %claim-special-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  ship-to-move
            (ship-to-move u.game-state)
          ::  check whether it's our turn
          ?.  =(+.ship-to-move src.bowl)
            :_  this
            =/  err  "cannot claim special draw on opponent's turn"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check if a special draw claim is available
          ?.  special-draw-available.u.game-state
            :_  this
            =/  err  "no special draw available for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  tell opponent we claim a special conditions draw
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[%'½–½']
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%end-game game-id.action %'½–½' ~])]
          ==  ==
        %request-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check that undo request doesn't already exist
          ?:  sent-undo-request.u.game-state
            :_  this
            =/  err  "undo request already exists for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check that we have made at least one move
          ?.  ?|  ?&  =(our.bowl white.game.u.game-state)
                      (gth (lent moves.game.u.game-state) 1)
                  ==
                  ?&  =(our.bowl black.game.u.game-state)
                      (gth (lent moves.game.u.game-state) 2)
              ==  ==
            :_  this
            =/  err  "no move to undo for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  send undo request to opponent
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/request-undo
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%undo-requested game-id.action])]
          ==  ==
        %undo-requested
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check that undo request doesn't already exist
          ?:  got-undo-request.u.game-state
            :_  this
            =/  err  "undo request already exists for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check that opponent has made at least one move
          ?.  ?|  ?&  =(src.bowl white.game.u.game-state)
                      (gth (lent moves.game.u.game-state) 1)
                  ==
                  ?&  =(src.bowl black.game.u.game-state)
                      (gth (lent moves.game.u.game-state) 2)
              ==  ==
            :_  this
            =/  err  "no move to undo for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update  !>([%undo-request game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(got-undo-request &))
          ==
        %decline-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open undo request
          ?.  got-undo-request.u.game-state
            :_  this
            =/  err  "no undo request to decline for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            ::  decline undo request
            ::  we don't care if opponent acks/nacks
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/decline-undo
                    %agent  [opponent.u.game-state %chess]
                    %poke
                    [%chess-action !>([%undo-declined game-id.action])]
            ==  ==
          ::  record that undo request is gone
          %=  this
            games  (~(put by games) game-id.action u.game-state(got-undo-request |))
          ==
        %undo-declined
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open undo request
          ?.  sent-undo-request.u.game-state
            :_  this
            =/  err  "{<our.bowl>} did not send undo request for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update  !>([%undo-declined game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(sent-undo-request |))
          ==
        %accept-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open undo request
          ?.  got-undo-request.u.game-state
            :_  this
            =/  err  "no undo request to decline for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  accept undo request
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/accept-undo
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%undo-accepted game-id.action])]
          ==  ==
        %undo-accepted
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =*  game  game.u.game-state
          ::  check for open undo request
          ?.  sent-undo-request.u.game-state
            :_  this
            =/  err  "{<our.bowl>} did not send undo request for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  ship-to-move
            (ship-to-move u.game-state)
          =:
              moves.game
            ?:  =(+.ship-to-move our.bowl)
              (snip (snip moves.game))
            (snip moves.game)
          ::
              position.u.game-state
            ?:  =(+.ship-to-move our.bowl)
              (fen-to-position (head (tail (rear (snip (snip moves.game))))))
            (fen-to-position (head (tail (rear (snip moves.game)))))
          ::
              sent-undo-request.u.game-state
            |
          ==
          :-
            ::  update observers that the undo request was accepted
            :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%undo-accepted game-id.action (position-to-fen position.u.game-state) ?:(=(+.ship-to-move our.bowl) ~.2 ~.1)])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state)
          ==
        %make-move
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  ship-to-move
            (ship-to-move u.game-state)
          ::  check whether it's our turn
          ?.  =(+.ship-to-move src.bowl)
            :_  this
            =/  err  "not our move"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check if the move is legal
          =/  move-result  (try-move u.game-state move.action)
          ::  reject invalid moves
          ?~  new.move-result
            :_  this
            =/  err  "invalid move for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =*  new-game-state  u.new.move-result
          ::  handle our end on ack
          :_
            %=  this
              games  (~(put by games) game-id.action u.game-state(move-in-progress `move.action))
            ==
          ::  did we win?
          ?~  result.game.new-game-state
            ::  special draw available?
            ?:  ?&  special-draw-available.new-game-state
                    auto-claim-special-draws.u.game-state
                ==
              ::  tell opponent we claim a special conditions draw
              :~  :*  %pass
                      /poke/game/(scot %da game-id.action)/ended/[%'½–½']
                      %agent  [opponent.u.game-state %chess]
                      %poke
                      [%chess-action !>([%end-game game-id.action %'½–½' `move.action])]
              ==  ==
            ::  regular move
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/move
                    %agent  [opponent.u.game-state %chess]
                    %poke
                    [%chess-action !>([%receive-move game-id.action move.action])]
            ==  ==
          ::  tell opponent we won
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[(need result.game.new-game-state)]
                  %agent  [opponent.u.game-state %chess]
                  %poke
                  [%chess-action !>([%end-game game-id.action (need result.game.new-game-state) `move.action])]
          ==  ==
        %receive-move
          ::  XX: opponent's move means draw declined
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  ship-to-move
            (ship-to-move u.game-state)
          ::  check whether it's opponent's turn
          ?.  =(+.ship-to-move src.bowl)
            :_  this
            =/  err  "not our move"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check if the move is legal
          =/  move-result  (try-move u.game-state move.action)
          ::  reject invalid moves
          ?~  new.move-result
            :_  this
            =/  err  "invalid move for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =*  new-game-state  u.new.move-result
          ?.  =(~ result.game.new-game-state)
            =/  san  (~(algebraicize with-position position.u.game-state) move.action)
            :_  this
            =/  err  "unexpected result for game {<game-id.action>} after move {<san>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-  cards.move-result
          %=  this
            games  (~(put by games) game-id.action new-game-state)
          ==
        %end-game
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  is there a move associated with the result?
          ?~  move.action
            ::  is opponent claiming a draw?
            ?:  =(result.action %'½–½')
              ::  is there an open draw offer?
              ?.  ?|  sent-draw-offer.u.game-state
                      special-draw-available.u.game-state
                  ==
                :_  this
                =/  err  "{<our.bowl>} did not send draw offer for {<game-id.action>}"
                :~  [%give %poke-ack `~[leaf+err]]
                ==
              :-
                ::  update observers that game ended in a draw
                :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                        %chess-update
                        !>([%result game-id.action result.action])
                    ==
                    ::  and kick subscribers who are listening to this agent
                    :*  %give  %kick  [/game/(scot %da game-id.action)/updates ~]
                        ~
                ==  ==
              %=  this
                ::  remove this game from our map of active games
                games    (~(del by games) game-id.action)
                ::  add this game to our archive
                archive  (~(put by archive) game-id.action game.u.game-state(result `result.action))
              ==
            ::  is opponent resigning?
            ?.  .=  result.action
                ?:  =(our.bowl +.white.game.u.game-state)
                  %'1-0'
                %'0-1'
              :_  this
              =/  err  "{<our.bowl>} does not resign game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
            :-
              ::  update observers that we won
              :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update
                      !>([%result game-id.action result.action])
                  ==
                  ::  and kick subscribers who are listening to this agent
                  :*  %give  %kick  [/game/(scot %da game-id.action)/updates ~]
                      ~
              ==  ==
            %=  this
              ::  remove this game from our map of active games
              games    (~(del by games) game-id.action)
              ::  add this game to our archive
              archive  (~(put by archive) game-id.action game.u.game-state(result `result.action))
            ==
          ::  apply move
          =/  move-result  (try-move u.game-state (need move.action))
          ::  reject invalid moves
          ?~  new.move-result
            :_  this
            =/  err  "invalid move for game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =*  result-game-state  u.new.move-result
          ::  is opponent claiming a special draw?
          ?:  =(result.action %'½–½')
            ::  is a draw now available?
            ?.  special-draw-available.result-game-state
              =/  san  (~(algebraicize with-position position.u.game-state) u.move.action)
              :_  this
              =/  err  "no special draw available for game {<game-id.action>} after {<san>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
            :-
              ::  update observers that game ended in a draw
              :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update
                      !>([%result game-id.action result.action])
                  ==
                  ::  and kick subscribers who are listening to this agent
                  :*  %give  %kick  [/game/(scot %da game-id.action)/updates ~]
                      ~
              ==  ==
            %=  this
              ::  remove this game from our map of active games
              games    (~(del by games) game-id.action)
              ::  add this game to our archive
              archive  (~(put by archive) game-id.action game.result-game-state(result `result.action))
            ==
          ::  is there a result?
          ?~  result.game.result-game-state
            =/  san  (~(algebraicize with-position position.u.game-state) u.move.action)
            :_  this
            =/  err  "move {<san>} does not end game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  has opponent won?
          ?.  =(result.action u.result.game.result-game-state)
            :_  this
            =/  err  "{<src.bowl>} does not win game {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            ::  update observers that we lost
            :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%result game-id.action result.action])
                ==
                ::  and kick subscribers who are listening to this agent
                :*  %give  %kick  [/game/(scot %da game-id.action)/updates ~]
                    ~
            ==  ==
          %=  this
            ::  remove this game from our map of active games
            games    (~(del by games) game-id.action)
            ::  add this game to our archive
            archive  (~(put by archive) game-id.action game.result-game-state)
          ==
        %change-special-draw-preference
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err  "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%special-draw-preference game-id.action setting.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(auto-claim-special-draws setting.action))
          ==
      ==
    ::
    ::  handle incoming challenges
    %chess-challenge
      =/  challenge  !<(chess-challenge vase)
      :-  :~  :*  %give  %fact  ~[/challenges]
                  %chess-update  !>([%challenge-received src.bowl challenge])
              ==
          ==
      %=  this
        challenges-received
          (~(put by challenges-received) src.bowl challenge)
      ==
    ::
    ::  handle declined challenges
    %chess-decline-challenge
      :-  :~  :*  %give  %fact   ~[/challenges]
                  %chess-update  !>([%challenge-resolved src.bowl])
              ==
          ==
      %=  this
        challenges-sent  (~(del by challenges-sent) src.bowl)
      ==
    ::
    ::  randomly assign sides for new games
    ::
    ::  sides are determined by a game of odds-or-evens using random numbers
    ::
    ::  order of ops:
    ::    1. acceptor pokes challenger w/ %commit
    ::    2. challenger pokes acceptor w/ %commit
    ::    3. acceptor pokes challenger w/ %reveal
    ::    4. challenger pokes acceptor w/ %reveal
    ::       challenger computes which side he should be and updates local challenge data
    ::    5. acceptor computes which side he should be and updates local challenge data
    ::       acceptor begins game as usual
    ::
    ::  all above-described pokes use %chess-rng mark
    %chess-rng
      =/  rng-data  !<(chess-rng vase)
      =/  commitment  (~(get by rng-state) src.bowl)
      ?-  -.rng-data
          %commit
        ?~  commitment
          ::  step 2 of assigning random sides
          =/  challenge  (~(get by challenges-sent) src.bowl)
          ::  check if challenge exists
          ?~  challenge
            :_  this
            =/  err  "{<our.bowl>} has not challenged us"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  choose random number, hash it, and send the hash to the acceptor
          =/  our-num  (shaf now.bowl eny.bowl)
          =/  our-hash  (shaf %chess-rng our-num)
          :-
            :~  :*  %pass  /poke/rng/commit  %agent  [src.bowl %chess]
                    %poke  %chess-rng  !>([%commit our-hash])
            ==  ==
          ::  record our number, our hash, and acceptor's hash
          %=  this
            rng-state  (~(put by rng-state) src.bowl [our-num our-hash ~ `p.rng-data |])
          ==
        ::  step 3 of assigning random sides
        =/  updated-commitment
          [our-num.u.commitment our-hash.u.commitment ~ `p.rng-data &]
        :-
          ::  reveal our random number
          :~  :*  %pass  /poke/rng/reveal  %agent  [src.bowl %chess]
                  %poke  %chess-rng  !>([%reveal our-num.u.commitment])
          ==  ==
        ::  record the challenger's hash
        %=  this
          rng-state  (~(put by rng-state) src.bowl updated-commitment)
        ==
      ::
          %reveal
        ?>  ?=(^ commitment)
        ?:  revealed.u.commitment
          ::  step 5 of assigning random sides
          ?>  ?=(^ her-hash.u.commitment)
          =*  her-num   p.rng-data
          =*  her-hash  u.her-hash.u.commitment
          ::  verify that challenger's number results in correct hash
          ?.  =(her-hash (shaf %chess-rng her-num))
            =/  bad-hash  (shaf %chess-rng her-num)
            :_  this
            =/  err  "hash mismatch for revealed commitment {<her-num>}: {<bad-hash>} vs. {<her-hash>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  mix numbers and use final bit to assign sides:
          ::    1 = acceptor is white
          ::    0 = challenger is white
          =/  random-bit
            %-  ?
            (end [0 1] (mix our-num.u.commitment her-num))
          =+  ^=  [our-side her-side]
            ?:  random-bit
              [%white %black]
            [%black %white]
          =/  challenge  (~(got by challenges-received) src.bowl)
          =/  game-id
            (mix now.bowl (end [3 6] eny.bowl))
          :-
            ::  attempt to accept game
            ::  handle our end on ack
            :~  :*  %pass
                    /poke/game/(scot %da game-id)/init
                    %agent
                    [src.bowl %chess]
                    %poke
                    [%chess-action !>([%game-accepted game-id our-side])]
            ==  ==
          %=  this
            challenges-received  (~(put by challenges-received) src.bowl challenge(challenger-side her-side))
          ==
        ::  step 4 of assigning random sides
        ?>  ?=(^ her-hash.u.commitment)
        =*  her-num   p.rng-data
        =*  her-hash  u.her-hash.u.commitment
        ::  verify that acceptor's number results in correct hash
        ?.  =(her-hash (shaf %chess-rng her-num))
          =/  bad-hash  (shaf %chess-rng her-num)
          :_  this
          =/  err  "hash mismatch for revealed commitment {<her-num>}: {<bad-hash>} vs. {<her-hash>}"
          :~  [%give %poke-ack `~[leaf+err]]
          ==
        =/  final-commitment
          :*  our-num.u.commitment
              our-hash.u.commitment
              `her-num
              `her-hash
              &
          ==
        ::  reveal our number
        :-
          :~  :*  %pass
                  /poke/rng/final
                  %agent
                  [src.bowl %chess]
                  %poke
                  %chess-rng  !>([%reveal our-num.u.commitment])
          ==  ==
        ::  record acceptor's number
        %=  this
          rng-state  (~(put by rng-state) src.bowl final-commitment)
        ==
      ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:default path)
    ::
    ::  get all challenge updates
    [%challenges ~]
      ?>  =(our.bowl src.bowl)
      :_  this
      %-  zing
      %-  limo
      ::  challenges sent
      :-  %+  turn  ~(tap by challenges-sent)
          |=  [who=ship challenge=chess-challenge]
          ^-  card
          :*  %give  %fact   ~
              %chess-update  !>([%challenge-sent who challenge])
          ==
      ::  challenges received
      :-  %+  turn  ~(tap by challenges-received)
          |=  [who=ship challenge=chess-challenge]
          ^-  card
          :*  %give  %fact   ~
              %chess-update  !>([%challenge-received who challenge])
          ==
      ~
    ::
    ::  convert active games to chess-game marks for subscribers
    [%active-games ~]
      ?>  =(our.bowl src.bowl)
      :_  this
      %+  turn  ~(tap by games)
      |=  [key=game-id game=chess-game * *]
      ^-  card
      :*  %give  %fact  ~
          %chess-game  !>(game)
      ==
    ::
    ::  handle frontend subscription to updates on a game
    [%game @ta %updates ~]
      =/  game-id  `(unit game-id)`(slaw %da i.t.path)
      ?~  game-id
        :_  this
        =/  err
          "invalid game id {<i.t.path>}"
        :~  [%give %watch-ack `~[leaf+err]]
        ==
      ?.  (~(has by games) u.game-id)
        :_  this
        =/  err
          "no active game with id {<u.game-id>}"
        :~  [%give %watch-ack `~[leaf+err]]
        ==
      =/  game-state  (~(got by games) u.game-id)
      =/  fen  (position-to-fen position.game-state)
      =/  cards  ^-  (list card)
        %+  spun
          moves.game.game-state
        |=  [move=[move=chess-move fen=chess-fen san=chess-san] player=chess-side]
        :-  :*  %give
                %fact
                ~[/game/(scot %da u.game-id)/updates]
                %chess-update
                !>  :*  %position
                        u.game-id
                        (get-squares move.move player)
                        fen.move
                        san.move
                        special-draw-available.game-state
            ==      ==
            (opposite-side player)
      =?  cards  got-draw-offer.game-state
        :_  cards
        :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
            %chess-update  !>([%draw-offer u.game-id])
        ==
      [cards this]
  ==
++  on-leave  on-leave:default
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:default path)
    ::
    ::  .^(noun %gx /=chess=/game/~1996.2.16..10.00.00..0000/noun)
    ::  read game info
    ::  either active or archived
    [%x %game @ta ~]
      =/  game-id  `(unit game-id)`(slaw %da i.t.t.path)
      ?~  game-id  `~
      =/  active-game  (~(get by games) u.game-id)
      ?~  active-game
        =/  archived-game  (~(get by archive) u.game-id)
        ?~  archived-game  ~
        ``[%chess-game !>(u.archived-game)]
      ``[%chess-game !>(game.u.active-game)]
    ::
    ::  .^(noun %gx /=chess=/challenges/outgoing/noun)
    ::  list challenges sent
    [%x %challenges %outgoing ~]
      ``[%chess-challenges !>(~(tap by challenges-sent))]
    ::
    ::  .^(noun %gx /=chess=/challenges/incoming/noun)
    ::  list challenges received
    [%x %challenges %incoming ~]
      ``[%chess-challenges !>(~(tap by challenges-received))]
    ::
    ::  .^(arch %gy /=chess=/games)
    ::  collect all the game-id keys
    [%y %games ~]
      :-  ~  :-  ~
      :-  %arch
      !>  ^-  arch
      :-  ~
      =/  ids  ~(tap in (~(uni in ~(key by archive)) ~(key by games)))
      %-  malt
      ^-  (list [@ta ~])
      %+  turn  ids
      |=  a=game-id
      [(scot %da a) ~]
    ::
    ::  .^(noun %gx /=chess=/friends/noun)
    ::  .^(json %gx /=chess=/friends/json)
    ::  read friends
    [%x %friends ~]
      ``[%chess-pals !>((~(mutuals pals bowl) ~.))]
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:default wire sign)
    [%poke %challenge %send ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          ::  if opponent has acked our challenge, add it to the frontned
          :_  this
          :~  :*  %give  %fact   ~[/challenges]
                  %chess-update  !>([%challenge-sent src.bowl (~(got by challenges-sent) src.bowl)])
          ==  ==
        ::  if not, print the error and consider the challenge declined
        %-  (slog u.p.sign)
        :-  ~
        %=  this
          challenges-sent  (~(del by challenges-sent) src.bowl)
        ==
      ==
    [%poke %challenge %reply ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          :_  this
          ::  if opponent has acked our rejection,
          ::  confirm that to our frontend
          :~  :*  %give  %fact   ~[/challenges]
                  %chess-update  !>([%challenge-replied src.bowl])
          ==  ==
        ::  if not, print the error
        %-  (slog u.p.sign)
        [~ this]
      ==
    [%poke %game game-id %init ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          =/  =game-id  (slav %da i.t.t.wire)
          =/  challenge  (~(got by challenges-received) src.bowl)
          ::  assign ships to white and black
          =+  ^=  [white-player black-player]
              ?:  ?=(%white challenger-side.challenge)
                [src.bowl our.bowl]
              [our.bowl src.bowl]
          ::  initialize new game
          =/  new-game
            ^-  chess-game
            :*  game-id
                (yule [d:(yell game-id) 0 0 0 ~])
                white-player
                black-player
                ~
                ~
            ==
          :-
              ::  add our new game to the list of active games
            :~  :*  %give  %fact  ~[/active-games]
                    %chess-game  !>(new-game)
                ==
                ::  tell our frontend we accepted the challenge
                :*  %give  %fact   ~[/challenges]
                    %chess-update  !>([%challenge-replied src.bowl])
                ==
            ==
          %=  this
            ::  remove our challenger from challenges-received
            challenges-received  (~(del by challenges-received) src.bowl)
            ::  put our new game into the map of games
            games  (~(put by games) game-id [new-game *chess-position ~ *(map @t @ud) | | | | | | src.bowl])
          ==
        ::  if nacked, print error
        %-  (slog u.p.sign)
        [~ this]
      ==
    [%poke %game game-id %offer-draw ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          =/  =game-id  (slav %da i.t.t.wire)
          =/  game-state
            ^-  active-game-state
            (~(got by games) game-id)
          :-  ~
          ::  record that draw has been offered
          %=  this
            games  (~(put by games) game-id game-state(sent-draw-offer &))
          ==
        ::  if nacked, print error
        %-  (slog u.p.sign)
        [~ this]
      ==
    [%poke %game game-id %request-undo ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          =/  =game-id  (slav %da i.t.t.wire)
          =/  game-state
            ^-  active-game-state
            (~(got by games) game-id)
          :-  ~
          ::  record that undo has been requested
          %=  this
            games  (~(put by games) game-id game-state(sent-undo-request &))
          ==
        ::  if nacked, print error
        %-  (slog u.p.sign)
        [~ this]
      ==
    [%poke %game game-id %accept-undo ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          =/  =game-id  (slav %da i.t.t.wire)
          =/  game-state
            ^-  active-game-state
            (~(got by games) game-id)
          =*  game  game.game-state
          =/  ship-to-move
            (ship-to-move game-state)
          =:
              moves.game
            ?:  =(+.ship-to-move our.bowl)
              (snip moves.game)
            (snip (snip moves.game))
          ::
              position.game-state
            ?:  =(+.ship-to-move our.bowl)
              (fen-to-position (head (tail (rear (snip moves.game)))))
            (fen-to-position (head (tail (rear (snip (snip moves.game))))))
          ::
              got-undo-request.game-state
            |
          ==
          :-
            ::  update observers that the undo request was accepted
            :~  :*  %give  %fact  ~[/game/(scot %da game-id)/updates]
                    %chess-update
                    !>([%undo-accepted game-id (position-to-fen position.game-state) ?:(=(+.ship-to-move our.bowl) ~.1 ~.2)])
            ==  ==
          %=  this
            games  (~(put by games) game-id game-state)
          ==
        ::  if nacked, print error
        ::  XX: maybe move this into %accept-undo?
        ::      if we try to accept and opponent nacks, that's kinda his problem...
        %-  (slog u.p.sign)
        [~ this]
      ==
    [%poke %game game-id %move ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        =/  =game-id  (slav %da i.t.t.wire)
        =/  game-state
          ^-  active-game-state
          (~(got by games) game-id)
        ?~  p.sign
          =/  move-result  (try-move game-state (need move-in-progress.game-state))
          ::  update position
          :-  cards.move-result
          %=  this
            games  (~(put by games) game-id (need new.move-result))
          ==
        ::  if nacked, print error
        ::  XX: what if this is nacked?
        ::      implies opponent cheating or major bug
        %-  (slog u.p.sign)
        :-  ~
        %=  this
          games  (~(put by games) game-id game-state(move-in-progress ~))
        ==
      ==
    [%poke %game game-id %ended chess-result ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ::  we don't care if opponent acks/nacks; game is over and that's that
        =/  agent-state
          =*  result  i.t.t.t.t.wire
          =/  =game-id  (slav %da i.t.t.wire)
          =/  game-state
            ^-  active-game-state
            (~(got by games) game-id)
          :-
            ::  update observers that game ended
            :~  :*  %give  %fact  ~[/game/(scot %da game-id)/updates]
                    %chess-update
                    !>([%result game-id result])
                ==
                ::  and kick subscribers who are listening to this agent
                :*  %give  %kick  [/game/(scot %da game-id)/updates ~]
                    ~
            ==  ==
          %=  this
            ::  remove this game from our map of active games
            games    (~(del by games) game-id)
            ::  add this game to our archive
            archive  (~(put by archive) game-id game.game-state(result `result))
          ==
        ?~  p.sign
          agent-state
        ::  print error if nack, then carry on
        %-  (slog u.p.sign)
        agent-state
      ==
    [%poke %rng %final ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ?~  p.sign
          ::  step 4 of assigning random sides, cont.
          =/  commitment  (~(got by rng-state) src.bowl)
          ::  mix numbers and use final bit to assign sides:
          ::    1 = acceptor is white
          ::    0 = challenger is white
          =/  random-bit
            %-  ?
            (end [0 1] (mix (need her-num.commitment) our-num.commitment))
          =/  our-side
            ?.  random-bit
              %white
            %black
          =/  challenge  (~(got by challenges-received) src.bowl)
          :-  ~
          %=  this
            challenges-sent  (~(put by challenges-sent) src.bowl challenge(challenger-side our-side))
          ==
        ::  if nacked, print error
        %-  (slog u.p.sign)
        [~ this]
      ==
  ==
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
|%
::
::  helper core for moves
::
::  test if a given move is legal
++  try-move
  |=  [game-state=active-game-state move=chess-move]
  ^-  [new=(unit active-game-state) cards=(list card)]
  ?.  ?=(~ result.game.game-state)
    [~ ~]
  =/  new-position
    (~(apply-move with-position position.game-state) move)
  ?~  new-position
    [~ ~]
  =/  updated-game  `chess-game`game.game-state
  =/  fen  (position-to-fen u.new-position)
  =/  san  (~(algebraicize with-position position.game-state) move)
  =.  moves.updated-game  (snoc moves.updated-game [move fen san])
  =/  new-fen-repetition  (increment-repetition fen-repetition.game-state u.new-position)
  =/  in-checkmate  ~(in-checkmate with-position u.new-position)
  =/  in-stalemate  ?:  in-checkmate
                      |
                    ~(in-stalemate with-position u.new-position)
  =/  special-draw-available
    ?|  (check-threefold new-fen-repetition u.new-position)
        (check-50-move-rule u.new-position)
    ==
  =/  special-draw-claim  &(special-draw-available auto-claim-special-draws.game-state)
  =/  position-update-card
    :*  %give
        %fact
        ~[/game/(scot %da game-id.game.game-state)/updates]
        %chess-update
        !>  :*  %position
                game-id.game.game-state
                (get-squares move player-to-move.u.new-position)
                (position-to-fen u.new-position)
                san
                special-draw-available
    ==      ==
  ::  check if game ends by checkmate, stalemate, or special draw
  ?:  ?|  in-checkmate
          in-stalemate
          special-draw-claim
      ==
      ::  update result with score
      =.  result.updated-game
        %-  some
        ?:  in-stalemate  %'½–½'
        ?:  special-draw-claim  %'½–½'
        ?:  in-checkmate
          ?-  player-to-move.u.new-position
            %white  %'0-1'
            %black  %'1-0'
          ==
        !!
      ::  give a card of the game result to opponent ship
      :-  `[updated-game u.new-position ~ new-fen-repetition special-draw-available |5.game-state]
      :~  position-update-card
      ==
  :-  `[updated-game u.new-position ~ new-fen-repetition special-draw-available |5.game-state]
  :~  position-update-card
  ==
++  ship-to-move
  |=  state=active-game-state
  ^-  chess-player
  ?-  player-to-move.position.state
    %white  white.game.state
    %black  black.game.state
  ==
++  increment-repetition
  |=  [fen-repetition=(map @t @ud) position=chess-position]
  ^-  (map @t @ud)
  =/  fen  ~(simplified position-to-fen position)
  =*  count  (~(get by fen-repetition) fen)
  ?~  count
    (~(put by fen-repetition) fen 1)
  (~(put by fen-repetition) fen +((need count)))
++  check-threefold
  |=  [fen-repetition=(map @t @ud) position=chess-position]
  ^-  ?
  =/  fen  ~(simplified position-to-fen position)
  =*  count  (~(get by fen-repetition) fen)
  ?~  count
    |
  (gth (need count) 2)
++  check-50-move-rule
   |=  position=chess-position
   ^-  ?
   (gte ply-50-move-rule.position 100)
--

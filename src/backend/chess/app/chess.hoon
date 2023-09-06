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
      potential-states=(map game-id (list (pair active-game-state card)))
      archive=((mop game-id chess-game) gth)
      challenges-sent=(map ship chess-challenge)
      challenges-received=(map ship chess-challenge)
      rng-state=(map ship chess-commitment)
  ==
+$  card  card:agent:gall
++  arch-orm  ((on game-id chess-game) gth)
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
    ::  pokes managing active game state and challenges, possibly sent by the user
    %chess-user-action
      ::  only allow chess actions from our ship or our moons
      ?>  =(our.bowl src.bowl)
      =/  action  !<(chess-user-action vase)
      ?-  -.action
        ::  manage new outgoing challenges
        %send-challenge
          ::  only allow one active challenge per ship
          ?:  (~(has by challenges-sent) who.action)
            %+  poke-nack  this
            "already challenged {<who.action>}"
          :_
            ::  add to list of outgoing challenges
            %=  this
              challenges-sent  (~(put by challenges-sent) +.action)
            ==
          ::  send new challenge
          :~  :*  %pass
                  /poke/challenge/send
                  %agent
                  [who.action %chess]
                  %poke
                  %chess-agent-action
                  !>([%challenge-received challenge.action])
          ==  ==
        %decline-challenge
          ::  check if challenge exists
          ?.  (~(has by challenges-received) who.action)
            %+  poke-nack  this
            "no challenge to decline from {<who.action>}"
          :_
            %=  this
              ::  remove our challenger from challenges-received
              challenges-received  (~(del by challenges-received) who.action)
            ==
          ::  tell our challenger we decline
          ::  we don't care about ack/nack
          :~  :*  %pass
                  /poke/challenge/decline
                  %agent
                  [who.action %chess]
                  %poke
                  %chess-agent-action
                  !>([%challenge-declined ~])
              ==
              ::  update observers that we replied to the challenge
              :*  %give
                  %fact
                  ~[/challenges]
                  %chess-update
                  !>([%challenge-replied who.action])
          ==  ==
        %accept-challenge
          =/  challenge  (~(get by challenges-received) who.action)
          ::  check if challenge exists
          ?~  challenge
            %+  poke-nack  this
            "no challenge to accept from {<who.action>}"
          ::  step 1 of assigning random sides
          ?:  ?=(%random challenger-side.u.challenge)
            =/  our-num  (shaf now.bowl eny.bowl)
            =/  our-hash  (shaf %chess-rng our-num)
            :_
              %=  this
                rng-state  (~(put by rng-state) who.action [our-num our-hash ~ ~ |])
              ==
            :~  :*  %pass
                    /poke/rng/commit
                    %agent
                    [who.action %chess]
                    %poke
                    %chess-rng
                    !>([%commit our-hash])
            ==  ==
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
                  %chess-agent-action
                  !>([%challenge-accepted game-id our-side])
          ==  ==
        %resign
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          =/  result
            ?:  =(our.bowl white.game.u.game-state)
              %'0-1'
            %'1-0'
          ::  resign
          ::  handle our end on ack
          :_
            %=  this
              ::  reset potential states on resignation
              potential-states  (~(put by potential-states) game-id.action ~)
            ==
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[result]
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%end-game game-id.action result ~])
          ==  ==
        %offer-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  send draw offer to opponent
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/offer-draw
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%draw-offered game-id.action])
          ==  ==
        %revoke-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open draw offer
          ?.  sent-draw-offer.u.game-state
            %+  poke-nack  this
            "no draw offer to revoke for game {<game-id.action>}"
          :-
            ::  revoke draw offer
            ::  we don't care if opponent acks/nacks
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/revoke-draw
                    %agent
                    [opponent.u.game-state %chess]
                    %poke
                    %chess-agent-action
                    !>([%draw-revoked game-id.action])
                ==
                :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%revoked-draw game-id.action])
            ==  ==
          %=  this
            ::  record that draw offer is gone
            games  (~(put by games) game-id.action u.game-state(sent-draw-offer |))
          ==
        %decline-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open draw offer
          ?.  got-draw-offer.u.game-state
            %+  poke-nack  this
            "no draw offer to decline for game {<game-id.action>}"
          :-
            ::  decline draw offer
            ::  we don't care if opponent acks/nacks
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/decline-draw
                    %agent
                    [opponent.u.game-state %chess]
                    %poke
                    %chess-agent-action
                    !>([%draw-declined game-id.action])
                ==
                :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%declined-draw game-id.action])
            ==  ==
          %=  this
            ::  record that draw offer is gone
            games  (~(put by games) game-id.action u.game-state(got-draw-offer |))
          ==
        %accept-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open draw offer
          ?.  got-draw-offer.u.game-state
            %+  poke-nack  this
            "no draw offer to accept for game {<game-id.action>}"
          ::  tell opponent we accept the draw
          ::  handle our end on ack
          :_
            %=  this
              ::  reset potential states on draw
              potential-states  (~(put by potential-states) game-id.action ~)
            ==
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[%'½–½']
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%end-game game-id.action %'½–½' ~])
          ==  ==
        %claim-special-draw
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          =/  ship-to-move
            (ship-to-move u.game-state)
          ::  check whether it's our turn
          ?.  =(ship-to-move src.bowl)
            %+  poke-nack  this
            "cannot claim special draw on opponent's turn"
          ::  check if a special draw claim is available
          ?.  special-draw-available.u.game-state
            %+  poke-nack  this
            "no special draw available for game {<game-id.action>}"
          ::  tell opponent we claim a special conditions draw
          ::  handle our end on ack
          :_
            %=  this
              ::  reset potential states on draw
              potential-states  (~(put by potential-states) game-id.action ~)
            ==
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[%'½–½']
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%end-game game-id.action %'½–½' ~])
          ==  ==
        %request-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check that undo request doesn't already exist
          ?:  sent-undo-request.u.game-state
            %+  poke-nack  this
            "undo request already exists for game {<game-id.action>}"
          ::  check that we have made at least one move
          =/  ship-to-move
            (ship-to-move u.game-state)
          ?.  ?|  ?&  =(our.bowl ship-to-move)
                      (gte (lent moves.game.u.game-state) 2)
                  ==
                  ?&  !=(our.bowl ship-to-move)
                      (gte (lent moves.game.u.game-state) 1)
              ==  ==
            %+  poke-nack  this
            "no move to undo for game {<game-id.action>}"
          ::  send undo request to opponent
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/request-undo
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%undo-requested game-id.action])
          ==  ==
        %revoke-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open undo request
          ?.  sent-undo-request.u.game-state
            %+  poke-nack  this
            "no undo request to revoke for game {<game-id.action>}"
          :-
            ::  decline undo request
            ::  we don't care if opponent acks/nacks
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/revoke-undo
                    %agent
                    [opponent.u.game-state %chess]
                    %poke
                    %chess-agent-action
                    !>([%undo-revoked game-id.action])
                ==
                :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%revoked-undo game-id.action])
            ==  ==
          ::  record that undo request is gone
          %=  this
            games  (~(put by games) game-id.action u.game-state(sent-undo-request |))
          ==
        %decline-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open undo request
          ?.  got-undo-request.u.game-state
            %+  poke-nack  this
            "no undo request to decline for game {<game-id.action>}"
          :-
            ::  decline undo request
            ::  we don't care if opponent acks/nacks
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/decline-undo
                    %agent
                    [opponent.u.game-state %chess]
                    %poke
                    %chess-agent-action
                    !>([%undo-declined game-id.action])
                ==
                :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%declined-undo game-id.action])
            ==  ==
          ::  record that undo request is gone
          %=  this
            games  (~(put by games) game-id.action u.game-state(got-undo-request |))
          ==
        %accept-undo
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open undo request
          ?.  got-undo-request.u.game-state
            %+  poke-nack  this
            "no undo request to decline for game {<game-id.action>}"
          ::  accept undo request
          ::  handle our end on ack
          :_  this
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/accept-undo
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%undo-accepted game-id.action])
          ==  ==
        %make-move
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          =/  ship-to-move
            (ship-to-move u.game-state)
          ::  check whether it's our turn
          ?.  =(ship-to-move src.bowl)
            %+  poke-nack  this
            "not our move"
          ::  check if the move is legal
          =/  move-result  (do-move u.game-state move.action)
          ::  reject invalid moves
          ?~  move-result
            %+  poke-nack
              %=  this
                ::  reset potential states after invalid move
                potential-states  (~(put by potential-states) game-id.action ~)
              ==
            "invalid move for game {<game-id.action>}"
          =*  new-game-state  new.u.move-result
          ::  handle our end on ack
          =/  future-states  (~(gut by potential-states) game-id.action ~)
          :_
            %=  this
              potential-states  (~(put by potential-states) game-id.action (snoc future-states u.move-result))
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
                      %agent
                      [opponent.u.game-state %chess]
                      %poke
                      %chess-agent-action
                      !>([%end-game game-id.action %'½–½' `move.action])
              ==  ==
            ::  regular move
            :~  :*  %pass
                    /poke/game/(scot %da game-id.action)/move
                    %agent
                    [opponent.u.game-state %chess]
                    %poke
                    %chess-agent-action
                    !>([%receive-move game-id.action move.action])
            ==  ==
          ::  tell opponent we won
          :~  :*  %pass
                  /poke/game/(scot %da game-id.action)/ended/[(need result.game.new-game-state)]
                  %agent
                  [opponent.u.game-state %chess]
                  %poke
                  %chess-agent-action
                  !>([%end-game game-id.action (need result.game.new-game-state) `move.action])
          ==  ==
        %change-special-draw-preference
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          :_
            %=  this
              games  (~(put by games) game-id.action u.game-state(auto-claim-special-draws setting.action))
            ==
          :~  :*  %give
                  %fact
                  ~[/game/(scot %da game-id.action)/updates]
                  %chess-update
                  !>([%special-draw-preference game-id.action setting.action])
          ==  ==
      ==
    ::
    ::  pokes managing active game state and challenges sent by another chess agent
    %chess-agent-action
      =/  action  !<(chess-agent-action vase)
      ?-  -.action
        %challenge-received
          ::  don't check for existing challenge;
          ::  if it does it means something went wrong and we probably want to
          ::  overwrite the existing challenge
          :_
            %=  this
              ::  remove our challenger from challenges-received
              challenges-received  (~(put by challenges-received) src.bowl challenge.action)
            ==
          ::  update observers that we replied to the challenge
          :~  :*  %give
                  %fact
                  ~[/challenges]
                  %chess-update
                  !>([%challenge-received src.bowl challenge.action])
          ==  ==
        %challenge-declined
          :: check that challenge exists
          ?.  (~(has by challenges-sent) src.bowl)
            %+  poke-nack  this
            "{<our.bowl>} hasn't challenged you"
          :-
            ::  tell frontend our challenge was declined
            :~  :*  %give
                    %fact
                    ~[/challenges]
                    %chess-update
                    !>([%challenge-resolved src.bowl])
            ==  ==
          %=  this
            ::  remove our challenge from challenges-sent
            challenges-sent  (~(del by challenges-sent) src.bowl)
          ==
        %challenge-accepted
          =/  challenge  (~(get by challenges-sent) src.bowl)
          :: check that challenge exists
          ?~  challenge
            %+  poke-nack  this
            "{<our.bowl>} hasn't challenged you"
          ?:  =(her-side.action challenger-side.u.challenge)
            %+  poke-nack  this
            "{<our.bowl>} expects to be {<her-side.action>}"
          ::  assign ships to white and black
          =+  ^=  [white-player black-player]
              ?:  ?=(%white her-side.action)
                [src.bowl our.bowl]
              [our.bowl src.bowl]
          ::  initialize new game
          =/  new-game
            ^-  chess-game
            :*  game-id.action
                event.u.challenge
                (yule [d:(yell game-id.action) 0 0 0 ~])
                white-player
                black-player
                ~
                ~
            ==
          :-
            ::  add our new game to the list of active games
            :~  :*  %give
                    %fact
                    ~[/active-games]
                    %chess-game-active
                    !>(new-game)
                ==
                ::  tell our frontend our challenge was accepted
                :*  %give
                    %fact
                    ~[/challenges]
                    %chess-update
                    !>([%challenge-resolved src.bowl])
            ==  ==
          %=  this
            ::  remove our challenge from challenges-sent
            challenges-sent  (~(del by challenges-sent) src.bowl)
            ::  put our new game into the map of games
            games  (~(put by games) game-id.action [new-game *chess-position *(map @t @ud) | | | | | | src.bowl])
          ==
        %draw-offered
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%draw-offered game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(got-draw-offer &))
          ==
        %draw-revoked
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open draw offer
          ?.  got-draw-offer.u.game-state
            %+  poke-nack  this
            "{<our.bowl>} did not receive draw offer for {<game-id.action>}"
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%draw-revoked game-id.action])
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
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for sent draw offer
          ?.  sent-draw-offer.u.game-state
            %+  poke-nack  this
            "{<our.bowl>} did not send draw offer for {<game-id.action>}"
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%draw-declined game-id.action])
            ==  ==
          %=  this
            ::  record that draw offer is gone
            games  (~(put by games) game-id.action u.game-state(sent-draw-offer |))
          ==
        %undo-requested
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check that undo request doesn't already exist
          ?:  got-undo-request.u.game-state
            %+  poke-nack  this
            "undo request already exists for game {<game-id.action>}"
          ::  check that opponent has made at least one move
          =/  ship-to-move
            (ship-to-move u.game-state)
          ?.  ?|  ?&  =(our.bowl ship-to-move)
                      (gte (lent moves.game.u.game-state) 1)
                  ==
                  ?&  !=(our.bowl ship-to-move)
                      (gte (lent moves.game.u.game-state) 2)
              ==  ==
            %+  poke-nack  this
            "no move to undo for game {<game-id.action>}"
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%undo-requested game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(got-undo-request &))
          ==
        %undo-revoked
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open undo request
          ?.  got-undo-request.u.game-state
            %+  poke-nack  this
            "{<our.bowl>} did not receive undo request for {<game-id.action>}"
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%undo-revoked game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(sent-undo-request |))
          ==
        %undo-declined
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          ::  check for open undo request
          ?.  sent-undo-request.u.game-state
            %+  poke-nack  this
            "{<our.bowl>} did not send undo request for game {<game-id.action>}"
          :-
            :~  :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%undo-declined game-id.action])
            ==  ==
          %=  this
            games  (~(put by games) game-id.action u.game-state(sent-undo-request |))
          ==
        %undo-accepted
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          =*  game  game.u.game-state
          ::  check for open undo request
          ?.  sent-undo-request.u.game-state
            %+  poke-nack  this
            "{<our.bowl>} did not send undo request for game {<game-id.action>}"
          =/  ship-to-move
            (ship-to-move u.game-state)
          =/  updated-moves
            ?:  =(ship-to-move our.bowl)
              (snip (snip moves.game))
            (snip moves.game)
          =:
              moves.game
            updated-moves
          ::
              position.u.game-state
            ?~  updated-moves
              *chess-position
            ?:  =(ship-to-move our.bowl)
              (fen-to-position (head (tail (rear (snip (snip moves.game))))))
            (fen-to-position (head (tail (rear (snip moves.game)))))
          ::
              sent-undo-request.u.game-state
            |
          ==
          :_
            %=  this
              games  (~(put by games) game-id.action u.game-state)
            ==
          ::  update observers that the undo request was accepted
          :~  :*  %give
                  %fact
                  ~[/game/(scot %da game-id.action)/updates]
                  %chess-update
                  !>([%undo-accepted game-id.action (position-to-fen position.u.game-state) ?:(=(ship-to-move our.bowl) ~.2 ~.1)])
          ==  ==
        %receive-move
          ::  XX: opponent's move means draw declined
          =/  game-state
            ^-  (unit active-game-state)
            (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            %+  poke-nack  this
            "no active game with id {<game-id.action>}"
          =/  ship-to-move
            (ship-to-move u.game-state)
          ::  check whether it's opponent's turn
          ?.  =(ship-to-move src.bowl)
            %+  poke-nack  this
            "not our move"
          ::  check if the move is legal
          =/  move-result  (do-move u.game-state move.action)
          ::  reject invalid moves
          ?~  move-result
            %+  poke-nack  this
            "invalid move for game {<game-id.action>}"
          =*  new-game-state  new.u.move-result
          ?.  =(~ result.game.new-game-state)
            =/  san  (~(algebraicize with-position position.u.game-state) move.action)
            %+  poke-nack  this
            "unexpected result for game {<game-id.action>} after move {<san>}"
          :-  [card.u.move-result ~]
          %=  this
            games  (~(put by games) game-id.action new-game-state)
          ==
        %end-game
          |^
            =/  game-state
              ^-  (unit active-game-state)
              (~(get by games) game-id.action)
            ::  check for valid game
            ?~  game-state
              %+  poke-nack  this
              "no active game with id {<game-id.action>}"
            ::  is there a move associated with the result?
            ?~  move.action
              ::  is opponent claiming a draw?
              ?:  =(result.action %'½–½')
                ::  is there an open draw offer?
                ?:  ?|  sent-draw-offer.u.game-state
                        special-draw-available.u.game-state
                    ==
                  (output-quip game.u.game-state(result `result.action) ~)
                %+  poke-nack  this
                "{<our.bowl>} did not send draw offer for {<game-id.action>}"
              ::  is opponent resigning?
              ?:  .=  result.action
                  ?:  =(our.bowl white.game.u.game-state)
                    %'1-0'
                  %'0-1'
                (output-quip game.u.game-state(result `result.action) ~)
              %+  poke-nack  this
              "{<our.bowl>} does not resign game {<game-id.action>}"
            ::  apply move
            =/  move-result  (do-move u.game-state (need move.action))
            ::  reject invalid moves
            ?~  move-result
              %+  poke-nack  this
              "invalid move for game {<game-id.action>}"
            =*  result-game-state  new.u.move-result
            ::  is opponent claiming a special draw?
            ?:  =(result.action %'½–½')
              ::  is a draw now available?
              ?:  special-draw-available.result-game-state
                (output-quip game.result-game-state(result `result.action) (bind move-result tail))
              =/  san  (~(algebraicize with-position position.u.game-state) u.move.action)
              %+  poke-nack  this
              "no special draw available for game {<game-id.action>} after {<san>}"
            ::  is there a result?
            ?~  result.game.result-game-state
              =/  san  (~(algebraicize with-position position.u.game-state) u.move.action)
              %+  poke-nack  this
              "move {<san>} does not end game {<game-id.action>}"
            ::  has opponent won?
            ?:  =(result.action u.result.game.result-game-state)
              (output-quip game.result-game-state (bind move-result tail))
            %+  poke-nack  this
            "{<src.bowl>} does not win game {<game-id.action>}"
          ++  output-quip
            |=  [archived-game=chess-game move=(unit card)]
            :_
              %=  this
                ::  remove game from our map of active games
                games    (~(del by games) game-id.action)
                ::  add game to our archive
                archive  (put:arch-orm archive game-id.action archived-game)
              ==
            %+  weld
              ::  send move update, if any
              (drop move)
            ::  archive finished game
            ^-  (list card)
            :~  :*  %give
                    %fact
                    ~[/archived-games]
                    %chess-game-archived
                    !>(archived-game)
                ==
                ::  update observers with game result
                :*  %give
                    %fact
                    ~[/game/(scot %da game-id.action)/updates]
                    %chess-update
                    !>([%result game-id.action result.action])
                ==
                ::  kick subscribers who are listening to this agent
                :*  %give
                    %kick
                    ~[/game/(scot %da game-id.action)/updates]
                    ~
            ==  ==
          --
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
            %+  poke-nack  this
            "{<our.bowl>} has not challenged us"
          ::  choose random number, hash it, and send the hash to the acceptor
          =/  our-num  (shaf now.bowl eny.bowl)
          =/  our-hash  (shaf %chess-rng our-num)
          :_
            ::  record our number, our hash, and acceptor's hash
            %=  this
              rng-state  (~(put by rng-state) src.bowl [our-num our-hash ~ `p.rng-data |])
            ==
          :~  :*  %pass
                  /poke/rng/commit
                  %agent
                  [src.bowl %chess]
                  %poke
                  %chess-rng
                  !>([%commit our-hash])
          ==  ==
        ::  step 3 of assigning random sides
        =/  updated-commitment
          [our-num.u.commitment our-hash.u.commitment ~ `p.rng-data &]
        :_
          ::  record the challenger's hash
          %=  this
            rng-state  (~(put by rng-state) src.bowl updated-commitment)
          ==
        ::  reveal our random number
        :~  :*  %pass
                /poke/rng/reveal
                %agent
                [src.bowl %chess]
                %poke
                %chess-rng
                !>([%reveal our-num.u.commitment])
        ==  ==
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
            %+  poke-nack  this
            "hash mismatch for revealed commitment {<her-num>}: {<bad-hash>} vs. {<her-hash>}"
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
          :_
            %=  this
              challenges-received   (~(put by challenges-received) src.bowl challenge(challenger-side her-side))
              rng-state             (~(del by rng-state) src.bowl)
            ==
          ::  attempt to accept game
          ::  handle our end on ack
          :~  :*  %pass
                  /poke/game/(scot %da game-id)/init
                  %agent
                  [src.bowl %chess]
                  %poke
                  %chess-agent-action
                  !>([%challenge-accepted game-id our-side])
          ==  ==
        ::  step 4 of assigning random sides
        ?>  ?=(^ her-hash.u.commitment)
        =*  her-num   p.rng-data
        =*  her-hash  u.her-hash.u.commitment
        ::  verify that acceptor's number results in correct hash
        ?.  =(her-hash (shaf %chess-rng her-num))
          =/  bad-hash  (shaf %chess-rng her-num)
            %+  poke-nack  this
            "hash mismatch for revealed commitment {<her-num>}: {<bad-hash>} vs. {<her-hash>}"
        =/  final-commitment
          :*  our-num.u.commitment
              our-hash.u.commitment
              `her-num
              `her-hash
              &
          ==
        ::  reveal our number
        :_
          ::  record acceptor's number
          %=  this
            rng-state  (~(put by rng-state) src.bowl final-commitment)
          ==
        :~  :*  %pass
                /poke/rng/final
                %agent
                [src.bowl %chess]
                %poke
                %chess-rng
                !>([%reveal our-num.u.commitment])
        ==  ==
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
          :*  %give
              %fact
              ~
              %chess-update
              !>([%challenge-sent who challenge])
          ==
      ::  challenges received
      :-  %+  turn  ~(tap by challenges-received)
          |=  [who=ship challenge=chess-challenge]
          ^-  card
          :*  %give
              %fact
              ~
              %chess-update
              !>([%challenge-received who challenge])
          ==
      ~
    ::
    ::  convert active games to chess-game-active marks for subscribers
    [%active-games ~]
      ?>  =(our.bowl src.bowl)
      :_  this
      %+  turn  ~(tap by games)
      |=  [key=game-id game=chess-game * *]
      ^-  card
      :*  %give
          %fact
          ~
          %chess-game-active
          !>(game)
      ==
    ::
    ::  convert archived games to chess-game-archived marks for frontend
    [%archived-games ~]
      ?>  (team:title our.bowl src.bowl)
      :_  this
      %+  turn  (tap:arch-orm archive)
      |=  [key=game-id game=chess-game]
      ^-  card
      :*  %give
          %fact
          ~
          %chess-game-archived
          !>(game)
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
        :*  %give
            %fact
            ~[/game/(scot %da u.game-id)/updates]
            %chess-update
            !>([%draw-offer u.game-id])
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
      =/  archived-game  (get:arch-orm archive u.game-id)
      ?~  archived-game  ~
      ``[%chess-game-archived !>(u.archived-game)]
    ``[%chess-game-active !>(game.u.active-game)]
    ::
    ::  .^(noun %gx /=chess=/game/~1996.2.16..10.00.00..0000/moves/noun)
    ::  list moves of chess-game for browsing
      [%x %game @ta %moves ~]
    =/  game-id  `(unit game-id)`(slaw %da i.t.t.path)
    ?~  game-id  `~
    =/  active-game  (~(get by games) u.game-id)
    ?~  active-game
      =/  archived-game  (get:arch-orm archive u.game-id)
      ?~  archived-game  ~
      ``[%chess-moves !>(u.archived-game)]
    ``[%chess-moves !>(game.u.active-game)]
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
    ::
    ::  XX: peek-bad-result if %pals not installed
    ::      should check %pals exists on this ship first
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
          :~  :*  %give
                  %fact
                  ~[/challenges]
                  %chess-update
                  !>([%challenge-sent src.bowl (~(got by challenges-sent) src.bowl)])
          ==  ==
        ::  if not, print the error and consider the challenge declined
        %-  (slog u.p.sign)
        :-  ~
        %=  this
          challenges-sent  (~(del by challenges-sent) src.bowl)
        ==
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
                event.challenge
                (yule [d:(yell game-id) 0 0 0 ~])
                white-player
                black-player
                ~
                ~
            ==
          :-
              ::  add our new game to the list of active games
            :~  :*  %give
                    %fact
                    ~[/active-games]
                    %chess-game-active
                    !>(new-game)
                ==
                ::  tell our frontend we accepted the challenge
                :*  %give
                    %fact
                    ~[/challenges]
                    %chess-update
                    !>([%challenge-replied src.bowl])
                ==
            ==
          %=  this
            ::  remove our challenger from challenges-received
            challenges-received  (~(del by challenges-received) src.bowl)
            ::  put our new game into the map of games
            games  (~(put by games) game-id [new-game *chess-position *(map @t @ud) | | | | | | src.bowl])
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
          :_
            ::  record that draw has been offered
            %=  this
              games  (~(put by games) game-id game-state(sent-draw-offer &))
            ==
          :~  :*  %give
                  %fact
                  ~[/game/(scot %da game-id)/updates]
                  %chess-update
                  !>([%offered-draw game-id])
          ==  ==
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
          :_
            ::  record that undo has been requested
            %=  this
              games  (~(put by games) game-id game-state(sent-undo-request &))
            ==
          :~  :*  %give
                  %fact
                  ~[/game/(scot %da game-id)/updates]
                  %chess-update
                  !>([%requested-undo game-id])
          ==  ==
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
          =/  updated-moves
            ?:  =(ship-to-move our.bowl)
              (snip moves.game)
            (snip (snip moves.game))
          =:
              moves.game
            ?:  =(ship-to-move our.bowl)
              (snip moves.game)
            (snip (snip moves.game))
              moves.game
            updated-moves
          ::
              position.game-state
            ?~  updated-moves
              *chess-position
            ?:  =(ship-to-move our.bowl)
              (fen-to-position (head (tail (rear (snip moves.game)))))
            (fen-to-position (head (tail (rear (snip (snip moves.game))))))
          ::
              got-undo-request.game-state
            |
          ==
          :_
            %=  this
              games  (~(put by games) game-id game-state)
            ==
          ::  update observers that the undo request was accepted
          :~  :*  %give
                  %fact
                  ~[/game/(scot %da game-id)/updates]
                  %chess-update
                  !>([%accepted-undo game-id (position-to-fen position.game-state) ?:(=(ship-to-move our.bowl) ~.1 ~.2)])
          ==  ==
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
          =/  future-states
            ^-  (list (pair active-game-state card))
            (~(got by potential-states) game-id)
          ?<  ?=(~ future-states)
          =*  next-state  i.future-states
          ::  update position
          :-  [q.next-state ~]
          %=  this
            ::  move game forward one state
            games             (~(put by games) game-id p.next-state)
            ::  move potential states one state forward
            potential-states  (~(put by potential-states) game-id t.future-states)
          ==
        ::  if nacked, print error
        ::  XX: what if this is nacked?
        ::      implies opponent cheating or major bug
        %-  (slog u.p.sign)
        :-  ~
        %=  this
          ::  reset potential states
          potential-states  (~(put by potential-states) game-id ~)
        ==
      ==
    [%poke %game game-id %ended chess-result ~]
      ?+  -.sign  (on-agent:default wire sign)
          %poke-ack
        ::  we don't care if opponent acks/nacks; game is over and that's that
        =/  agent-state
          =*  result  i.t.t.t.t.wire
          =/  =game-id  (slav %da i.t.t.wire)
          =+
            ^=  [game-state move]
            ^-  [active-game-state (unit card)]
            ?~  states=(~(gut by potential-states) game-id ~)
              [(~(got by games) game-id) ~]
            [-.i.states (some +.i.states)]
          =*  updated-game  game.game-state
          =.  result.updated-game  `result
          :_
            %=  this
              ::  remove this game from our map of active games
              games    (~(del by games) game-id)
              ::  add this game to our archive
              archive  (put:arch-orm archive game-id updated-game)
            ==
          %+  weld
            (drop move)
          ^-  (list card)
          ::  archive finished game
          :~  :*  %give
                  %fact
                  ~[/archived-games]
                  %chess-game-archived
                  !>(updated-game)
              ==
              ::  update observers that game ended
              :*  %give
                  %fact
                  ~[/game/(scot %da game-id)/updates]
                  %chess-update
                  !>([%result game-id result])
              ==
              ::  and kick subscribers who are listening to this agent
              :*  %give
                  %kick
                  ~[/game/(scot %da game-id)/updates]
                  ~
          ==  ==
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
          =/  challenge  (~(got by challenges-sent) src.bowl)
          :-  ~
          %=  this
            challenges-sent   (~(put by challenges-sent) src.bowl challenge(challenger-side our-side))
            rng-state         (~(del by rng-state) src.bowl)
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
::  helper core
+|  %game-logic
::
::  try to apply a move
++  do-move
  |=  [game-state=active-game-state move=chess-move]
  ^-  (unit [new=active-game-state =card])
  ?.  ?=(~ result.game.game-state)
    ~
  %+  bind
    (~(apply-move with-position position.game-state) move)
  |=  new-position=chess-position
  ^-  [new=active-game-state =card]
  =/  fen
    (position-to-fen new-position)
  =/  new-fen-repetition
    (increment-repetition fen-repetition.game-state new-position)
  =/  san
    (~(algebraicize with-position position.game-state) move)
  =/  in-checkmate
    ~(in-checkmate with-position new-position)
  =/  in-stalemate
    ?:  in-checkmate
      |
    ~(in-stalemate with-position new-position)
  =/  special-draw-available
    ?|  (check-threefold new-fen-repetition new-position)
        (check-50-move-rule new-position)
    ==
  =/  special-draw-claim
    &(special-draw-available auto-claim-special-draws.game-state)
  =/  result
    ^-  (unit chess-result)
    ?.  ?|  in-checkmate
            in-stalemate
            special-draw-claim
        ==
      ~
    %-  some
    ?.  in-checkmate
      %'½–½'
    ?-  player-to-move.new-position
      %white  %'0-1'
      %black  %'1-0'
    ==
  =/  updated-game
    %=  game.game-state
      result  result
      moves   (snoc moves.game.game-state [move fen san])
    ==
  :-
    :*  updated-game
        new-position
        new-fen-repetition
        special-draw-available
        |4.game-state
    ==
  :*  %give
      %fact
      ~[/game/(scot %da game-id.game.game-state)/updates]
      %chess-update
      !>  :*  %position
              game-id.game.game-state
              (get-squares move player-to-move.new-position)
              (position-to-fen new-position)
              san
              special-draw-available
  ==      ==
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
+|  %convenience
++  ship-to-move
  |=  state=active-game-state
  ^-  chess-player
  ?-  player-to-move.position.state
    %white  white.game.state
    %black  black.game.state
  ==
++  poke-nack
  |*  [this=agent:gall msg=tape]
  ^-  (quip card _this)
  :_  this
  :~  [%give %poke-ack `~[leaf+msg]]
  ==
--

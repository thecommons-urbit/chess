::  chess: fully decentralized, peer-to-peer chess app for urbit
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
      ready=?
      sent-draw-offer=?
      got-draw-offer=?
      auto-claim-special-draws=?
      sent-undo-request=?
      got-undo-request=?
  ==
+$  state-1
  $:  %1
      games=(map @dau active-game-state)
      archive=((mop @dau chess-game) lth)
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
  ^-  (quip card _this)
  :_  this
  ::
  ::  XX: remove these cards
  ::
  ::  these are initialization steps from before
  ::  the software distribution update and should be removed
  :~  :*  %pass  /srv
          %agent  [our.bowl %file-server]
          %poke  %file-server-action
          !>([%serve-dir /'~chess' /app/chess | &])
      ==
      :*  %pass  /chess
          %agent  [our.bowl %launch]
          %poke  %launch-action
          !>  :*  %add  %chess
                  [[%basic 'chess' '' '/~chess'] &]
              ==
      ==
  ==
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
      ?>  (team:title our.bowl src.bowl)
      =/  action  !<(chess-action vase)
      ?-  -.action
        ::  manage new outgoing challenges
        %challenge
          ::  only allow one active challenge per ship
          ::  XX: change or display to frontend
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
        %accept-game
          =/  challenge  (~(get by challenges-received) who.action)
          ?~  challenge
            :_  this
            =/  err
              "no challenge to accept from {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  XX: document chess-rng
          ?:  ?=(%random challenger-side.u.challenge)
            =/  our-num  (shaf now.bowl eny.bowl)
            =/  our-hash  (shaf %chess-rng our-num)
            :-  :~  :*  %pass  /poke/rng  %agent  [who.action %chess]
                        %poke  %chess-rng  !>([%commit our-hash])
                    ==
                ==
            %=  this
              rng-state  %+  ~(put by rng-state)  who.action
                         [our-num our-hash ~ ~ |]
            ==
          ::  assign ships to white and black
          =+  ^=  [white-player black-player]
            ?-  challenger-side.u.challenge
              %white
                [[%ship who.action] [%ship our.bowl]]
              %black
                [[%ship our.bowl] [%ship who.action]]
            ==
          ::  create a unique game id
          =/  game-id  (mix now.bowl (end [3 6] eny.bowl))
          ::  initialize new game
          =/  new-game  ^-  chess-game
            :*  game-id=game-id
                event=event.u.challenge
                site='Urbit Chess'
                date=(yule [d:(yell game-id) 0 0 0 ~])
                round=round.u.challenge
                white=white-player
                black=black-player
                result=~
                moves=~
            ==
          ::  subscribe to moves made on the
          ::  other player's instance of this game
          :-  :~  :*  %pass  /player/(scot %da game-id)
                      %agent  [who.action %chess]
                      %watch  /game/(scot %da game-id)/moves
                  ==
                  ::  add our new game to the list of active games
                  :*  %give  %fact  ~[/active-games]
                      %chess-game  !>(new-game)
                  ==
                  ::  tell our frontend we accepted the challenge
                  :*  %give  %fact   ~[/challenges]
                      %chess-update  !>([%challenge-replied who.action])
                  ==
              ==
          %=  this
            ::  remove our challenger from challenges-received
            challenges-received  (~(del by challenges-received) who.action)
            ::  if the poke came from our ship, delete
            ::  the challenge from our `challenges-sent`
            challenges-sent  ?:  =(who.action our.bowl)
                               (~(del by challenges-sent) our.bowl)
                             challenges-sent
            ::  put our new game into the map of games
            games  (~(put by games) game-id [new-game *chess-position *(map @t @ud) | | | | | | |])
          ==
        %decline-game
          =/  challenge  (~(get by challenges-received) who.action)
          ?~  challenge
            :_  this
            =/  err
              "no challenge to decline from {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  tell our challenger we decline
          :-  :~  :*  %pass  /poke/challenge/reply  %agent  [who.action %chess]
                      %poke  %chess-decline-challenge  !>(~)
                  ==
              ==
          %=  this
            ::  remove our challenger from challenges-received
            challenges-received  (~(del by challenges-received) who.action)
          ==
        %change-special-draw-preference
          =/  game  (~(get by games) game-id.action)
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-  :~  :*  %give
                      %fact
                      ~[/game/(scot %da game-id.action)/updates]
                      %chess-update
                      !>([%special-draw-preference game-id.action setting.action])
                  ==
              ==
          %=  this
            games  (~(put by games) game-id.action u.game(auto-claim-special-draws setting.action))
          ==
        %offer-draw
          =/  game  (~(get by games) game-id.action)
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  send draw offer to opponent
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-draw-offer  !>(~)
                  ==
              ==
          ::  record that draw has been offered
          %=  this
            games  (~(put by games) game-id.action u.game(sent-draw-offer &))
          ==
        %accept-draw
          =/  game-state  (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open draw offer
          ?.  got-draw-offer.u.game-state
            :_  this
            =/  err
              "no draw offer to accept for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          ::  tell opponent we accept the draw
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-draw-accept  !>(~)
                  ==
                  ::  update observers that game ended in a draw
                  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update
                      !>([%result game-id.action %'½–½'])
                  ==
                  ::  and kick subscribers who are listening to this agent
                  :*  %give  %kick  :~  /game/(scot %da game-id.action)/updates
                                        /game/(scot %da game-id.action)/moves
                                    ==
                      ~
                  ==
              ==
          =/  updated-game  game.u.game-state
          =.  result.updated-game  `(unit chess-result)``%'½–½'
          %=  this
            ::  remove this game from our map of active games
            games    (~(del by games) game-id.action)
            ::  add this game to our archive
            archive  (~(put by archive) game-id.action updated-game)
          ==
        %decline-draw
          =/  game  (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open draw offer
          ?.  got-draw-offer.u.game
            :_  this
            =/  err
              "no draw offer to decline for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          ::  decline draw offer
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-draw-decline  !>(~)
                  ==
              ==
          %=  this
            ::  record that draw offer is gone
            games  (~(put by games) game-id.action u.game(got-draw-offer |))
          ==
        %claim-special-draw
          =/  game-state  (~(get by games) game-id.action)
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  ship-to-move
            ?-  player-to-move.position.u.game-state
              %white
                white.game.u.game-state
              %black
                black.game.u.game-state
            ==
          ::  check whether it's our turn
          ?>  ?=([%ship @p] ship-to-move)
          ?.  (team:title +.ship-to-move src.bowl)
            :_  this
            =/  err
              "cannot claim special draw on opponent's turn"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check if a special draw claim is available
          ?.  special-draw-available.u.game-state
            :_  this
            =/  err
              "no special draw available for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-game-result  !>([game-id.action %'½–½' ~])
                  ==
                  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update
                      !>([%result game-id.action %'½–½'])
                  ==
                  :*  %give  %kick  :~  /game/(scot %da game-id.action)/updates
                                        /game/(scot %da game-id.action)/moves
                                    ==
                      ~
                  ==
              ==
          =/  updated-game  game.u.game-state
          =.  result.updated-game  `(unit chess-result)``%'½–½'
          %=  this
            games    (~(del by games) game-id.action)
            archive  (~(put by archive) game-id.action updated-game)
          ==
        %move
          =/  game-state  (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :: check opponent is subscribed to our updates
          ?.  ready.u.game-state
            :_  this
            =/  err
              "opponent not subscribed yet"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  else, check whose move it should be right now
          =/  ship-to-move
            ?-  player-to-move.position.u.game-state
              %white
                white.game.u.game-state
              %black
                black.game.u.game-state
            ==
          ::  check whether it's our turn
          ?>  ?=([%ship @p] ship-to-move)
          ?.  (team:title +.ship-to-move src.bowl)
            :_  this
            =/  err
              "not our move"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  move-result
            (try-move u.game-state move.action)
          ::  check the move is legal
          ?~  new.move-result
            :_  this
            =/  err
              "illegal move"
            %+  weld  cards.move-result
            ^-  (list card)
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =,  u.new.move-result
          :-  ?:  &(auto-claim-special-draws special-draw-available)
                ::  don't send extra move card if auto-claiming special draw
                cards.move-result
              ::  send move to opponent
              :_  cards.move-result
              :*  %give
                  %fact
                  ~[/game/(scot %da game-id.action)/moves]
                  %chess-move
                  !>(move.action)
              ==
          ::  check if game is over
          ?.  ?=(~ result.game)
            ::  if so, archive game
            %=  this
              games    (~(del by games) game-id.action)
              archive  (~(put by archive) game-id.action game)
            ==
          ::  otherwise, update position
          %=  this
            games  %+  ~(put by games)  game-id.action
                   u.new.move-result
          ==
        %resign
          =/  game-state  (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  result
            ?:  =(our.bowl +.white.game.u.game-state)
              %'0-1'
             %'1-0'
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-game-result  !>([game-id.action result ~])
                  ==
                  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update
                      !>([%result game-id.action result])
                  ==
                  :*  %give  %kick  :~  /game/(scot %da game-id.action)/updates
                                        /game/(scot %da game-id.action)/moves
                                    ==
                      ~
                  ==
              ==
          %=  this
            games    (~(del by games) game-id.action)
            archive  (~(put by archive) game-id.action game.u.game-state(result `result))
          ==
        %request-undo
          =/  game  (~(get by games) game-id.action)
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  send undo request to opponent
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-undo-request  !>(~)
                  ==
                  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update  !>([%undo-request game-id.action])
                  ==
              ==
          ::  record that undo has been requested
          %=  this
            games  (~(put by games) game-id.action u.game(sent-undo-request &))
          ==
        %decline-undo
          =/  game  (~(get by games) game-id.action)
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  check for open undo request
          ?.  got-undo-request.u.game
            :_  this
            =/  err
              "no undo request to decline for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          ::  decline undo request
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-undo-decline  !>(~)
                  ==
                  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update  !>([%undo-declined game-id.action])
                  ==
              ==
          %=  this
            ::  record that undo request is gone
            games  (~(put by games) game-id.action u.game(got-undo-request |))
          ==
        %accept-undo
          =/  game-state  (~(get by games) game-id.action)
          ::  check for valid game
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =,  u.game-state
          ::  check for open undo request
          ?.  got-undo-request
            :_  this
            =/  err
              "no undo request to decline for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          ::  tell opponent we accept the undo request
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-undo-accept  !>(~)
                  ==
                  ::  update observers that we accept the undo request
                  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                      %chess-update  !>([%undo-accepted game-id.action])
                  ==
              ==
          =/  ship-to-move
            ?-  player-to-move.position.u.game-state
              %white  white.game
              %black  black.game
            ==
          ?>  ?=([%ship @p] ship-to-move)
          =:
            moves.game.u.game-state  ?:  =(+.ship-to-move our.bowl)
                                       (snip moves.game)
                                     (snip (snip moves.game))
            position.u.game-state  ?:  =(+.ship-to-move our.bowl)
                                     (fen-to-position (head (tail (rear (snip moves.game)))))
                                   (fen-to-position (head (tail (rear (snip (snip moves.game))))))
            got-undo-request.u.game-state  |
          ==
          %=  this
            games  (~(put by games) game-id.action u.game-state)
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
    ::  XX further document rng logic
    %chess-rng
      =/  rng-data  !<(chess-rng vase)
      =/  commitment  (~(get by rng-state) src.bowl)
      ?-  -.rng-data
        %commit
          ?~  commitment
            ::  we're the challenger
            =/  our-num  (shaf now.bowl eny.bowl)
            =/  our-hash  (shaf %chess-rng our-num)
            :-  :~  :*  %pass  /poke/rng  %agent  [src.bowl %chess]
                        %poke  %chess-rng  !>([%commit our-hash])
                    ==
                ==
            %=  this
              rng-state  %+  ~(put by rng-state)  src.bowl
                         [our-num our-hash ~ `p.rng-data |]
            ==
          :: we're the accepter
          =/  updated-commitment
            [our-num.u.commitment our-hash.u.commitment ~ `p.rng-data &]
          :-  :~  :*  %pass  /poke/rng  %agent  [src.bowl %chess]
                      %poke  %chess-rng  !>([%reveal our-num.u.commitment])
                  ==
              ==
          %=  this
            rng-state  (~(put by rng-state) src.bowl updated-commitment)
          ==
        %reveal
          ?>  ?=(^ commitment)
          ?:  revealed.u.commitment
            ::  we're the accepter
            ?>  ?=(^ her-hash.u.commitment)
            ?.  =(u.her-hash.u.commitment (shaf %chess-rng p.rng-data))
              ~|  commitment  !!  ::  cheater
            =/  challenge  (~(get by challenges-received) src.bowl)
            ?~  challenge  !!
            =/  random-bit  %-  ?
              (end [0 1] (mix our-num.u.commitment p.rng-data))
            =/  white-player
              ?:  random-bit
                [%ship our.bowl]
              [%ship src.bowl]
            =/  black-player
              ?:  random-bit
                [%ship src.bowl]
              [%ship our.bowl]
            =/  game-id  (mix now.bowl (end [3 6] eny.bowl))
            =/  new-game  ^-  chess-game
              :*  game-id=game-id
                  event=event.u.challenge
                  site='Urbit Chess'
                  date=(yule [d:(yell game-id) 0 0 0 ~])
                  round=round.u.challenge
                  white=white-player
                  black=black-player
                  result=~
                  moves=~
              ==
            :-  :~  :*  %pass  /player/(scot %da game-id)
                        %agent  [src.bowl %chess]
                        %watch  /game/(scot %da game-id)/moves
                    ==
                    :*  %give  %fact  ~[/active-games]
                        %chess-game  !>(new-game)
                    ==
                    :*  %give  %fact   ~[/challenges]
                        %chess-update  !>([%challenge-replied src.bowl])
                    ==
                ==
            %=  this
              challenges-received  (~(del by challenges-received) src.bowl)
              challenges-sent  ?:  =(src.bowl our.bowl)
                                 (~(del by challenges-sent) our.bowl)
                               challenges-sent
              rng-state  (~(del by rng-state) src.bowl)
              games  (~(put by games) game-id [new-game *chess-position *(map @t @ud) | | | | | | |])
            ==
          ::  we're the challenger
          ?>  ?=(^ her-hash.u.commitment)
          ?.  =(u.her-hash.u.commitment (shaf %chess-rng p.rng-data))
            ~|  commitment  !!::  cheater
          =/  final-commitment
            :*  our-num.u.commitment
                our-hash.u.commitment
                `p.rng-data
                her-hash.u.commitment
                &
            ==
          :-  :~  :*  %pass  /poke/rng  %agent  [src.bowl %chess]
                      %poke  %chess-rng  !>([%reveal our-num.u.commitment])
                  ==
              ==
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
      ?>  (team:title our.bowl src.bowl)
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
      ?>  (team:title our.bowl src.bowl)
      :_  this
      %+  turn  ~(tap by games)
      |=  [key=@dau game=chess-game * *]
      ^-  card
      :*  %give  %fact  ~
          %chess-game  !>(game)
      ==
    ::
    ::  starts a new game
    [%game @ta %moves ~]
      =/  game-id  `(unit @dau)`(slaw %da i.t.path)
      ?~  game-id
        :_  this
        =/  err
          "invalid game id {<i.t.path>}"
        :~  [%give %watch-ack `~[leaf+err]]
        ==
      ?:  (~(has by games) u.game-id)
        =/  game-state  (~(got by games) u.game-id)
        ?:  ready.game-state
          [~ this]
        =/  players  [white.game.game-state black.game.game-state]
        ::  ensure that the players in a game are our ship and the requesting ship
        ?:  ?|  =(players [[%ship our.bowl] [%ship src.bowl]])
                =(players [[%ship src.bowl] [%ship our.bowl]])
            ==
          :-  ~
          =/  new-game-state  game-state(ready &)
          %=  this
            games  (~(put by games) u.game-id new-game-state)
          ==
        [~ this]
      =/  challenge  (~(get by challenges-sent) src.bowl)
      ?~  challenge
        :_  this
        =/  err
          "no active game with id {<u.game-id>} or challenge from {<src.bowl>}"
        :~  [%give %watch-ack `~[leaf+err]]
        ==
      ::
      ::  assign white and black to players if random was chosen
      ?:  ?=(%random challenger-side.u.challenge)
        =/  commitment  (~(got by rng-state) src.bowl)
        =/  random-bit  %-  ?
          (end [0 1] (mix our-num.commitment (need her-num.commitment)))
        =/  white-player
          ?:  random-bit
            [%ship src.bowl]
          [%ship our.bowl]
        =/  black-player
          ?:  random-bit
            [%ship our.bowl]
          [%ship src.bowl]
        =/  new-game  ^-  chess-game
          :*  game-id=u.game-id
              event=event.u.challenge
              site='Urbit Chess'
              date=(yule [d:(yell u.game-id) 0 0 0 ~])
              round=round.u.challenge
              white=white-player
              black=black-player
              result=~
              moves=~
          ==
        ::  subscribe to updates from the other player's agent
        :-  :~  :*  %pass  /player/(scot %da u.game-id)
                    %agent  [src.bowl %chess]
                    %watch  /game/(scot %da u.game-id)/moves
                ==
                ::  send the new game as an update to the other player's agent
                :*  %give  %fact  ~[/active-games]
                    %chess-game  !>(new-game)
                ==
                ::  tell our frontend our challenge was accepted
                :*  %give  %fact   ~[/challenges]
                    %chess-update  !>([%challenge-resolved src.bowl])
                ==
            ==
        %=  this
          challenges-sent  (~(del by challenges-sent) src.bowl)
          rng-state  (~(del by rng-state) src.bowl)
          games  (~(put by games) u.game-id [new-game *chess-position *(map @t @ud) | & | | | | |])
        ==
      ::  assign white and black to players if challenger chose
      =+  ^=  [white-player black-player]
        ?-  challenger-side.u.challenge
          %white
            [[%ship our.bowl] [%ship src.bowl]]
          %black
            [[%ship src.bowl] [%ship our.bowl]]
        ==
      =/  new-game  ^-  chess-game
            :*  game-id=u.game-id
                event=event.u.challenge
                site='Urbit Chess'
                date=(yule [d:(yell u.game-id) 0 0 0 ~])
                round=round.u.challenge
                white=white-player
                black=black-player
                result=~
                moves=~
            ==
      ::  subscribe to updates from the other player's agent
      :-  :~  :*  %pass  /player/(scot %da u.game-id)
                  %agent  [src.bowl %chess]
                  %watch  /game/(scot %da u.game-id)/moves
              ==
              ::  send the new game as an update to the other player's agent
              :*  %give  %fact  ~[/active-games]
                  %chess-game  !>(new-game)
              ==
              ::  tell our frontend our challenge was accepted
              :*  %give  %fact   ~[/challenges]
                  %chess-update  !>([%challenge-resolved src.bowl])
              ==
          ==
      %=  this
        challenges-sent  (~(del by challenges-sent) src.bowl)
        games  (~(put by games) u.game-id [new-game *chess-position *(map @t @ud) | & | | | | |])
      ==
    ::
    ::  handle frontend subscription to updates on a game
    [%game @ta %updates ~]
      =/  game-id  `(unit @dau)`(slaw %da i.t.path)
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
         %+  turn
           moves.game.game-state
         |=  move=[move=chess-move fen=chess-fen san=chess-san]
         :*  %give  %fact   ~[/game/(scot %da u.game-id)/updates]
             %chess-update  !>([%position u.game-id fen.move san.move special-draw-available.game-state])
         ==
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
    :: send back a list of chess-games
      [%x %archive *]
    ?+  t.t.path  (on-peek:default path)
    ::
    ::  =sur -build-file /=chess=/sur/chess/hoon
    ::  .^((map @dau chess-game:sur) %gx /=chess=/archive/all/noun)
    ::  .^(json %gx /=chess=/archive/all/json)
        [%all ~]
      ``[%chess-archive !>(archive)]
    ::
        [%before @ @ ~]
      =/  before=@  (rash i.t.t.t.path dem)
      =/  max=@  (rash i.t.t.t.t.path dem)
    :: XX: this produces a list
      ``[%chess-archive !>(tab:arch-orm archive `before max)]
    ::  XX: include more search criteria encoded in the path
    ::      ex: opponent    archive/ship
    ::          date range  archive/@da/@da
    ::          event/site  archive/@t
    ::          date area   archive/@da/@dr
    ::          latest #    archive/last/@ud
    ::          result      archive/result
    ::          side      archive/side
    ::
    ::      *range, opponent, and side would be better with
    ::      date range or a limit
    ::
    ::  XX:  archive will probably need to be a mop
    ::  if we want this to be ordered nicely.
    ::
    ::  collect only the latest 8 games in archive
    :: [%last @ud ~]
    ==
    ::
    ::  recieve game info
    ::    either pgn or chess-game form
    ::    or only recieve moves in a wain
      [%x %game @ta *]
    =/  game-id  `(unit @dau)`(slaw %da i.t.t.path)
    ?~  game-id  `~
    =/  active-game  (~(get by games) u.game-id)
    =/  archived-game  (~(get by archive) u.game-id)
    ?+  t.t.t.path  (on-peek:default path)
      ::
      :: .^(wain %gx /=chess=/game/~1996.2.16..10.00.00..0000/moves/noun)
        [%moves ~]
      ?~  active-game
        ?~  archived-game  ~
        ``[%chess-moves !>((algebraicize-and-number u.archived-game))]
      ``[%chess-moves !>((algebraicize-and-number game.u.active-game))]
      ::
      :: .^(wain %gx /=chess=/game/~1996.2.16..10.00.00..0000/pgn/noun)
      :: .^(mime %gx /=chess=/game/~1996.2.16..10.00.00..0000/pgn/mime)
        [%pgn ~]
      ?~  active-game
        ?~  archived-game  ~
        ``[%pgn !>((to-pgn u.archived-game))]
      ``[%pgn !>((to-pgn game.u.active-game))]
      ::
      :: .^(noun %gx /=chess=/game/~1996.2.16..10.00.00..0000/chess-game/noun)
        [%chess-game ~]
      ?~  active-game
        ?~  archived-game  ~
        ``[%chess-game !>(u.archived-game)]
      ``[%chess-game !>(game.u.active-game)]
    ==
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
    |=  a=@dau
    [(scot %da a) ~]
    ::
    ::  .^(noun %gx /=chess=/friends/noun)
    ::  .^(json %gx /=chess=/friends/json)
    ::  read mutual friends
      [%x %friends ~]
    ``[%chess-pals !>((~(mutuals pals bowl) ~.))]
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:default wire sign)
    ::
    ::  remove a sent challenge on nack
    [%poke %challenge %send ~]
      ?+  -.sign  (on-agent:default wire sign)
        %poke-ack
          ::  if opponent has acked our challenge, add it to the frontned
          ?~  p.sign
          ::
            :-  :~  :*  %give  %fact   ~[/challenges]
                        %chess-update  !>([%challenge-sent src.bowl (~(got by challenges-sent) src.bowl)])
                    ==
                ==
            this
          ::
          ::  XX: send a notification to the user that an error occurred
          ::
          ::  if not, print the error and
          ::  consider the challenge declined
          %-  (slog u.p.sign)
          :-  ~
          %=  this
            challenges-sent  (~(del by challenges-sent) src.bowl)
          ==
      ==
    ::
    :: get ack/nack when we reject a challenge
    [%poke %challenge %reply ~]
      ?+  -.sign  (on-agent:default wire sign)
        %poke-ack
          ?~  p.sign
          ::  if opponent has acked our rejection,
          ::  confirm that to our frontend
            :-  :~  :*  %give  %fact   ~[/challenges]
                        %chess-update  !>([%challenge-replied src.bowl])
                    ==
                ==
            this
          ::  if nacked, print error
          %-  (slog u.p.sign)
            [~ this]
      ==
    ::
    ::  handle actions from opponent player
    [%player @ta ~]
      =/  game-id  `(unit @dau)`(slaw %da i.t.wire)
      ?~  game-id
        [~ this]  ::  should leave the weird subscription here
      =/  game-state  (~(get by games) u.game-id)
      ?~  game-state
        [~ this]  ::  should leave the weird subscription here
      =/  ship-to-move
        ?-  player-to-move.position.u.game-state
          %white
            white.game.u.game-state
          %black
            black.game.u.game-state
        ==
      ?+  -.sign  (on-agent:default wire sign)
        %fact
          ?+  p.cage.sign  (on-agent:default wire sign)
            %chess-draw-offer
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update  !>([%draw-offer u.game-id])
                      ==
                  ==
              %=  this
                games  (~(put by games) u.game-id u.game-state(got-draw-offer &))
              ==
            %chess-draw-accept
              ::  first check whether we offered draw
              ?.  sent-draw-offer.u.game-state
                [~ this]  ::  nice try, cheater
              ::  log game as a draw, kick subscriber, and archive
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update
                          !>([%result u.game-id %'½–½'])
                      ==
                      :*  %give  %kick  :~  /game/(scot %da u.game-id)/updates
                                            /game/(scot %da u.game-id)/moves
                                        ==
                          ~
                      ==
                  ==
              =/  updated-game  game.u.game-state
              =.  result.updated-game  `%'½–½'
              %=  this
                games    (~(del by games) u.game-id)
                archive  (~(put by archive) u.game-id updated-game)
              ==
            %chess-draw-decline
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update  !>([%draw-declined u.game-id])
                      ==
                  ==
              %=  this
                games    (~(put by games) u.game-id u.game-state(sent-draw-offer |))
              ==
            ::
            ::  handle move legality, new games, and finished games
            %chess-move
              ::  ensure it’s the opponent ship’s turn
              ?.  =([%ship src.bowl] ship-to-move)
                [~ this]  :: nice try, cheater
              =/  move  !<(chess-move q.cage.sign)
              =/  move-result
                (try-move u.game-state move)
              ::  illegal move
              ?~  new.move-result
                [cards.move-result this]  ::  nice try, cheater
              =,  u.new.move-result
              :-  cards.move-result
              ?.  ?=(~ result.game)
              ::  archive games with results
                %=  this
                  games    (~(del by games) u.game-id)
                  archive  (~(put by archive) u.game-id game)
                ==
              ::  add new games to our list
              ::  XX: could this be where position update
              ::      isn't getting move data?
              %=  this
                games  %+  ~(put by games)  u.game-id
                       u.new.move-result
              ==
            %chess-game-result
              =/  result  !<(chess-game-result q.cage.sign)
              ::  is our opponent resigning or claiming a draw?
              ?.  =(result.result %'½–½')
                ?.  .=  result.result
                    ?:  =(our.bowl +.white.game.u.game-state)
                      %'1-0'
                    %'0-1'
                  [~ this]  ::  nice try, cheater
                :_  %=  this
                      games    (~(del by games) u.game-id)
                      archive  (~(put by archive) u.game-id game.u.game-state(result `result.result))
                    ==
                :~  :*  %give
                        %fact
                        ~[/game/(scot %da u.game-id)/updates]
                        %chess-update
                        !>([%result u.game-id result.result])
                    ==
                    :*  %give  %kick  :~  /game/(scot %da u.game-id)/updates
                                          /game/(scot %da u.game-id)/moves
                                      ==
                        ~
                    ==
                ==
              =/  result-game-state
                ?~  move.result
                  u.game-state
                =/  move-result  (try-move u.game-state (need move.result))
                ::  technically allows opponent to claim special draw with invalid move,
                ::  but only when a special draw is already available
                ::  so it doesn't break the game's correctness
                ?~  new.move-result
                  u.game-state
                u.new.move-result
              =,  result-game-state
              ?.  special-draw-available
                [~ this]  ::  nice try, cheater
              :_  %=  this
                    games    (~(del by games) u.game-id)
                    archive  (~(put by archive) u.game-id game.result-game-state(result `result.result))
                  ==
              :~  :*  %give
                      %fact
                      ~[/game/(scot %da u.game-id)/updates]
                      %chess-update
                      !>([%result u.game-id result.result])
                  ==
                  :*  %give  %kick  :~  /game/(scot %da u.game-id)/updates
                                        /game/(scot %da u.game-id)/moves
                                    ==
                      ~
                  ==
              ==
            %chess-undo-request
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update  !>([%undo-request u.game-id])
                      ==
                  ==
              %=  this
                games  (~(put by games) u.game-id u.game-state(got-undo-request &))
              ==
            %chess-undo-decline
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update  !>([%undo-declined u.game-id])
                      ==
                  ==
              %=  this
                games    (~(put by games) u.game-id u.game-state(sent-undo-request |))
              ==
            %chess-undo-accept
              ?.  sent-undo-request.u.game-state
                [~ this]
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update  !>([%undo-accepted u.game-id])
                      ==
                  ==
              =,  u.game-state
              =:
                moves.game.u.game-state  ?:  =(+.ship-to-move our.bowl)
                                           (snip (snip moves.game))
                                         (snip moves.game)
                position.u.game-state  ?:  =(+.ship-to-move our.bowl)
                                         (fen-to-position (head (tail (rear (snip (snip moves.game))))))
                                       (fen-to-position (head (tail (rear (snip moves.game)))))
                got-undo-request.u.game-state  |
              ==
              %=  this
                games  (~(put by games) u.game-id u.game-state)
              ==
          ==
      ==
  ==
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
|%
::
::  helper core for moves
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
        !>([%position game-id.game.game-state (position-to-fen u.new-position) san special-draw-available])
    ==
  ::  check if game ends by checkmate, stalemate, or special draw
  ?:  ?|  in-checkmate
          in-stalemate
          special-draw-claim
      ==
      ::  update result with score
      =.  result.updated-game
        ?:  in-stalemate  `%'½–½'
        ?:  special-draw-claim  `%'½–½'
        ?:  in-checkmate
          ?-  player-to-move.u.new-position
            %white  `%'0-1'
            %black  `%'1-0'
          ==
        !!
      ::  give a card of the game result to opponent ship
      :-  `[updated-game u.new-position new-fen-repetition special-draw-available |4.game-state]
      ?.  special-draw-claim
        :~  position-update-card
            :*  %give  %fact  ~[/game/(scot %da game-id.game.game-state)/updates]
                %chess-update
                !>([%result game-id.game.game-state (need result.updated-game)])
            ==
            ::  kick subscriber from game
            :*  %give  %kick  :~  /game/(scot %da game-id.game.game-state)/updates
                                  /game/(scot %da game-id.game.game-state)/moves
                              ==
                ~
            ==
        ==
      ::  if we're auto-claiming a special draw, send opponent our move with the result
      :~  position-update-card
          :*  %give  %fact  ~[/game/(scot %da game-id.game.game-state)/moves]
              %chess-game-result
              !>([game-id.game.game-state (need result.updated-game) `move])
          ==
          :*  %give  %fact  ~[/game/(scot %da game-id.game.game-state)/updates]
              %chess-update
              !>([%result game-id.game.game-state (need result.updated-game)])
          ==
          :*  %give  %kick  :~  /game/(scot %da game-id.game.game-state)/updates
                                /game/(scot %da game-id.game.game-state)/moves
                            ==
              ~
          ==
      ==
  :-  `[updated-game u.new-position new-fen-repetition special-draw-available |4.game-state]
  :~  position-update-card
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

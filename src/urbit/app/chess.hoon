/+  chess, dbug, default-agent, hark=hark-store
=,  chess
=,  hark
|%
+$  versioned-state
  $%  state-0
  ==
+$  active-game-state
  $:  game=chess-game
      position=chess-position
      ready=?
      sent-draw-offer=?
      got-draw-offer=?
  ==
+$  state-0
  $:  %0
      games=(map @dau active-game-state)
      archive=(map @dau chess-game)
      challenges-sent=(map ship chess-challenge)
      challenges-received=(map ship chess-challenge)
      rng-state=(map ship chess-commitment)
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %|) bowl)
    hc       ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
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
    %0  [~ this(state old-state)]
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:default mark vase)
    %chess-action
      ?>  (team:title our.bowl src.bowl)
      =/  action  !<(chess-action vase)
      ?-  -.action
        %challenge
          ?:  (~(has by challenges-sent) who.action)
            :_  this
            =/  err
              "already challenged {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-  :~  :*  %pass  /poke/challenge  %agent  [who.action %chess]
                      %poke  %chess-challenge  !>(challenge.action)
                  ==
              ==
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
          =+  ^=  [white-player black-player]
            ?-  challenger-side.u.challenge
              %white
                [[%ship who.action] [%ship our.bowl]]
              %black
                [[%ship our.bowl] [%ship who.action]]
            ==
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
                      %agent  [who.action %chess]
                      %watch  /game/(scot %da game-id)/moves
                  ==
                  :*  %give  %fact  ~[/active-games]
                      %chess-game  !>(new-game)
                  ==
              ==
          %=  this
            challenges-received  (~(del by challenges-received) who.action)
            challenges-sent  ?:  =(who.action our.bowl)
                               (~(del by challenges-sent) our.bowl)
                             challenges-sent
            games  (~(put by games) game-id [new-game *chess-position | | |])
          ==
        %decline-game
          =/  challenge  (~(get by challenges-received) who.action)
          ?~  challenge
            :_  this
            =/  err
              "no challenge to decline from {<who.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-  :~  :*  %pass  /poke/challenge  %agent  [who.action %chess]
                      %poke  %chess-decline-challenge  !>(~)
                  ==
              ==
          %=  this
            challenges-received  (~(del by challenges-received) who.action)
          ==
        %offer-draw
          =/  game  (~(get by games) game-id.action)
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-draw-offer  !>(~)
                  ==
              ==
          %=  this
            games  (~(put by games) game-id.action u.game(sent-draw-offer &))
          ==
        %accept-draw
          =/  game-state  (~(get by games) game-id.action)
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ?.  got-draw-offer.u.game-state
            :_  this
            =/  err
              "no draw offer to accept for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-draw-accept  !>(~)
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
        %decline-draw
          =/  game  (~(get by games) game-id.action)
          ?~  game
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ?.  got-draw-offer.u.game
            :_  this
            =/  err
              "no draw offer to decline for game {<game-id.action>}"
              :~  [%give %poke-ack `~[leaf+err]]
              ==
          :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-draw-decline  !>(~)
                  ==
              ==
          %=  this
            games  (~(put by games) game-id.action u.game(got-draw-offer |))
          ==
        %move
          =/  game-state  (~(get by games) game-id.action)
          ?~  game-state
            :_  this
            =/  err
              "no active game with id {<game-id.action>}"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ?.  ready.u.game-state
            :_  this
            =/  err
              "opponent not subscribed yet"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          ::  XX: investigate moving this to /lib/chess
          ::
          ::  this should probably go in /lib/chess, it's defined
          ::  3x in 3 different arms doing 3 slightly different
          ::  things. it might be worth doing a pass for other
          ::  bits of functionality that should go in /lib.
          ::  they might need to be standardized first.
          ::
          ::  the other advantage of this would be
          ::  exposing more functionality to the
          ::  -test thread, after which you could
          ::  write a test suite that covers a
          ::  lot of ground.
          =/  ship-to-move
            ?-  player-to-move.position.u.game-state
              %white
                white.game.u.game-state
              %black
                black.game.u.game-state
            ==
          ?>  ?=([%ship @p] ship-to-move)
          ?.  (team:title +.ship-to-move src.bowl)
            :_  this
            =/  err
              "not our move"
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =/  move-result
            (try-move:hc game.u.game-state position.u.game-state move.action)
          ?~  new.move-result
            :_  this
            =/  err
              "illegal move"
            %+  weld  cards.move-result
            ^-  (list card)
            :~  [%give %poke-ack `~[leaf+err]]
            ==
          =,  u.new.move-result
          :-  %+  weld  cards.move-result
              ^-  (list card)
              :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/moves]
                      %chess-move  !>(move.action)
                  ==
              ==
          ?.  ?=(~ result.game)
            %=  this
              games    (~(del by games) game-id.action)
              archive  (~(put by archive) game-id.action game)
            ==
          %=  this
            games  %+  ~(put by games)  game-id.action
                   [game position |2.u.game-state]
          ==
      ==
    %chess-challenge
      =/  challenge  !<(chess-challenge vase)
      :-  :~  :*  %give  %fact  ~[/challenges]
                  %chess-update  !>([%challenge src.bowl challenge])
              ==
              :*  =/  title=(list content)
                    ~[[%ship src.bowl] [%text ' has sent a challenge']]
                  =/  body=(list content)
                    ~[[%text event.challenge]]
                  =/  =bin
                    [/chess/challenges [%chess /challenges]]
                  =/  hark-action=action
                    ::  XX: should link to game
                    [%add-note bin title body now.bowl / /chess]
                  =/  =cage
                    [%hark-action !>(hark-action)]
                  [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
              ==
          ==
      %=  this
        challenges-received
          (~(put by challenges-received) src.bowl challenge)
      ==
    %chess-decline-challenge
      :-  :~  :*  =/  title=(list content)
                    ~[[%ship src.bowl] [%text ' declined your challenge']]
                  =/  =bin
                    [/chess/challenges [%chess /challenges]]
                  =/  hark-action=action
                    [%add-note bin title ~ now.bowl / /chess]
                  =/  =cage
                    [%hark-action !>(hark-action)]
                  [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
              ==
          ==
      %=  this
        challenges-sent  (~(del by challenges-sent) src.bowl)
      ==
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
                ==
            %=  this
              challenges-received  (~(del by challenges-received) src.bowl)
              challenges-sent  ?:  =(src.bowl our.bowl)
                                 (~(del by challenges-sent) our.bowl)
                               challenges-sent
              rng-state  (~(del by rng-state) src.bowl)
              games  (~(put by games) game-id [new-game *chess-position | | |])
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
    %chess-debug-inject
      ?>  =(src.bowl our.bowl)
      =/  action  !<([game-id=@dau game=chess-game] vase)
      =/  new-position  (play game.action)
      ?~  new-position
        :_  this
        =/  err
          "attempted to inject illegal game"
        :~  [%give %poke-ack `~[leaf+err]]
        ==
      =/  fen  (position-to-fen u.new-position)
      :-  :~  :*  %give  %fact  ~[/game/(scot %da game-id.action)/updates]
                  %chess-update  !>([%position game-id.action fen])
              ==
          ==
      %=  this
        games  (~(put by games) game-id.action [game.action u.new-position & | |])
      ==
    %chess-debug-subscribe
      ?>  =(src.bowl our.bowl)
      =/  action  !<([who=ship game-id=@dau] vase)
      :_  this
      :~  :*  %pass  /player/(scot %da game-id.action)
              %agent  [who.action %chess]
              %watch  /game/(scot %da game-id.action)/moves
          ==
      ==
    %chess-debug-zap
      ?>  =(src.bowl our.bowl)
      =/  action  !<(game-id=@dau vase)
      :-  ~
      %=  this
        games  (~(del by games) game-id.action)
      ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:default path)
    [%challenges ~]
      ?>  (team:title our.bowl src.bowl)
      :_  this
      %+  turn  ~(tap by challenges-received)
      |=  [who=ship challenge=chess-challenge]
      ^-  card
      :*  %give  %fact  ~
          %chess-update  !>([%challenge who challenge])
      ==
    [%active-games ~]
      ?>  (team:title our.bowl src.bowl)
      :_  this
      %+  turn  ~(tap by games)
      |=  [key=@dau game=chess-game * *]
      ^-  card
      :*  %give  %fact  ~
          %chess-game  !>(game)
      ==
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
        :-  :~  :*  %pass  /player/(scot %da u.game-id)
                    %agent  [src.bowl %chess]
                    %watch  /game/(scot %da u.game-id)/moves
                ==
                :*  %give  %fact  ~[/active-games]
                    %chess-game  !>(new-game)
                ==
                ::  notify us opponent accepted
                :*  =/  title=(list content)
                      ~[[%ship src.bowl] [%text ' accepts your challenge']]
                    =/  =bin
                      [/chess/challenges [%chess /challenges]]
                    =/  hark-action=action
                      ::  XX: should link to game
                      [%add-note bin title ~ now.bowl / /chess]
                    =/  =cage
                      [%hark-action !>(hark-action)]
                    [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
                ==
            ==
        %=  this
          challenges-sent  (~(del by challenges-sent) src.bowl)
          rng-state  (~(del by rng-state) src.bowl)
          games  (~(put by games) u.game-id [new-game *chess-position & | |])
        ==
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
      :-  :~  :*  %pass  /player/(scot %da u.game-id)
                  %agent  [src.bowl %chess]
                  %watch  /game/(scot %da u.game-id)/moves
              ==
              :*  %give  %fact  ~[/active-games]
                  %chess-game  !>(new-game)
              ==
          ==
      %=  this
        challenges-sent  (~(del by challenges-sent) src.bowl)
        games  (~(put by games) u.game-id [new-game *chess-position & | |])
      ==
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
        :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                %chess-update  !>([%position u.game-id fen])
            ==
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
    [%x %game @ta ~]
      =/  game-id  `(unit @dau)`(slaw %da i.t.t.path)
      ?~  game-id  `~
      =/  active-game  (~(get by games) u.game-id)
      ?~  active-game
        =/  archived-game  (~(get by archive) u.game-id)
        ?~  archived-game  ~
        ``[%chess-game !>(u.archived-game)]
      ``[%chess-game !>(game.u.active-game)]
    [%y %game ~]
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
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:default wire sign)
    [%poke %challenge ~]
      ?+  -.sign  (on-agent:default wire sign)
        %poke-ack
          ?~  p.sign
            [~ this]
          %-  (slog u.p.sign)
          :-
            ::  XX: frontend popup: ~sampel-palnet doesn't have %chess!
            ~
          %=  this
            challenges-sent  (~(del by challenges-sent) src.bowl)
          ==
      ==
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
                      ::  notify hark-store
                      :*  =/  title=(list content)
                            ~[[%ship src.bowl] [%text ' offers a draw']]
                          =/  =bin
                            [/chess/updates [%chess /games/(scot %da u.game-id)]]
                          =/  hark-action=action
                            ::  XX: should link to game
                            [%add-note bin title ~ now.bowl / /chess]
                          =/  =cage
                            [%hark-action !>(hark-action)]
                          [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
                      ==
                  ==
              %=  this
                games  (~(put by games) u.game-id u.game-state(got-draw-offer &))
              ==
            %chess-draw-accept
              ?.  sent-draw-offer.u.game-state
                [~ this]  ::  nice try, cheater
              :-  :~  :*  %give  %fact  ~[/game/(scot %da u.game-id)/updates]
                          %chess-update
                          !>([%result u.game-id %'½–½'])
                      ==
                      :*  %give  %kick  :~  /game/(scot %da u.game-id)/updates
                                            /game/(scot %da u.game-id)/moves
                                        ==
                          ~
                      ==
                      ::  notify hark-store
                      :*  =/  title=(list content)
                            ~[[%ship src.bowl] [%text ' accepts your draw offer']]
                          =/  =bin
                            [/chess/updates [%chess /games/(scot %da u.game-id)]]
                          =/  hark-action=action
                            ::  XX: should link to game
                            [%add-note bin title ~ now.bowl / /chess]
                          =/  =cage
                            [%hark-action !>(hark-action)]
                          [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
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
                      ::  notify hark-store
                      :*  =/  title=(list content)
                            ~[[%ship src.bowl] [%text ' declines your draw offer']]
                          =/  =bin
                            [/chess/updates [%chess /games/(scot %da u.game-id)]]
                          =/  hark-action=action
                            ::  XX: should link to game
                            [%add-note bin title ~ now.bowl / /chess]
                          =/  =cage
                            [%hark-action !>(hark-action)]
                          [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
                      ==
                  ==
              %=  this
                games    (~(put by games) u.game-id u.game-state(sent-draw-offer |))
              ==
            %chess-move
              ?.  =([%ship src.bowl] ship-to-move)
                [~ this]  :: nice try, cheater
              =/  move  !<(chess-move q.cage.sign)
              =/  move-result
                (try-move:hc game.u.game-state position.u.game-state move)
              ?~  new.move-result
                [cards.move-result this]  ::  nice try, cheater
              =,  u.new.move-result
              ::
              ::  XX: shouldn't notify if %chess is open
              ::  XX: post-Groups 2, should create more granular
              ::      notifications about moves:
              ::      '~sampel-palnet moves E5 pawn to E6'
              ::      '~sampel-palnet: check!'
              ::      '~sampel-palnet: checkmate!'
              ::      '~sampel-palnet promotes XX pawn to queen'
              ::
              ::  check if opponent has resigned
              ::  XX: must change %end check after GitHub issue #3 implemented
              ::  XX: notification: opponent resigned
              ?:  ?=(%end -.move)
                :-  cards.move-result
                %=  this
                  games    (~(del by games) u.game-id)
                  archive  (~(put by archive) u.game-id game)
                ==
              :-
                ~[cards.move-result]
              %=  this
                games  %+  ~(put by games)  u.game-id
                       [game position |2.u.game-state]
              ==
          ==
      ==
  ==
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
|_  =bowl:gall
++  try-move
  |=  [game=chess-game position=chess-position move=chess-move]
  ::  return [(unit [game position] (list card))]
  ^-  [new=(unit [game=chess-game position=chess-position]) cards=(list card)]
  ?.  ?=(~ result.game)
    [~ ~]
  =/  new-position  (~(apply-move with-position position) move)
  ?~  new-position
    [~ ~]
  =/  updated-game  `chess-game`game
  ::
  =.  moves.updated-game  (snoc moves.updated-game move)
  ::
  =/  fen  (position-to-fen u.new-position)
  ::
  =/  ship-to-move
    ?-  player-to-move.position
      %white
        white.game
      %black
        black.game
    ==
  ::
  =/  position-update-card
    :*  %give  %fact  ~[/game/(scot %da game-id.game)/updates]
        %chess-update  !>([%position game-id.game fen])
    ==
  ::  XX: why does this check [%ship @p] and not chess-player?
  ::      why include [%name @t] in chess-player at all if it breaks?
  ?>  ?=([%ship @p] ship-to-move)
  ?.  =(team:title +.ship-to-move)
    ::  causes need-have error
    [position-update-card ~]
  ::
  ::  define some stuff
  =/  in-checkmate
    ~(in-checkmate with-position u.new-position)
  ::
  =/  in-stalemate
    ?:  in-checkmate
      |
    ~(in-stalemate with-position u.new-position)
  ::
  =/  place
    :-  %chess
    ?:  |(in-checkmate in-stalemate)
      /games
    /games/(scot %da game-id.game)
  ::
  =/  notification-text
    %+  rap  3
      :~  `@`+.ship-to-move
          ?:  in-checkmate
            `@`': checkmate!'
          ?:  in-stalemate
            `@`' forced a stalemate'
          %+  rap  3
            :~
              `@`(~(algebraicize with-position u.new-position) move)
              ?.  ~(in-check with-position u.new-position)
                `@`' has made a move'
              `@`', check!'
            ==
      ==
  ::
  =/  notification-card
    :*  =/  title=(list content)
          [[%text notification-text] ~]
        =/  =bin
          [/chess/games place]
        =/  hark-action=action:hark
          [%add-note bin title ~ now.bowl / /chess]
        =/  =cage
          [%hark-action !>(hark-action)]
        [%pass /hark-store %agent [our.bowl %hark-store] %poke cage]
    ==
  ::
  =/  result-cards
    ?:  ?|  ?=(%end -.move)
            in-checkmate
            in-stalemate
        ==
      ::  if game has result
      =.  result.updated-game
        ?:  ?=(%end -.move)  `+.move
        ?:  in-stalemate  `%'½–½'
        ?:  in-checkmate
          ?-  player-to-move.u.new-position
            %white  `%'0-1'
            %black  `%'1-0'
          ==
        !!
      :~  :*  %give  %fact  ~[/game/(scot %da game-id.game)/updates]
              %chess-update
              !>([%result game-id.game (need result.updated-game)])
          ==
          :*  %give  %kick  :~  /game/(scot %da game-id.game)/updates
                                /game/(scot %da game-id.game)/moves
                            ==
              ~
          ==
          notification-card
          position-update-card
      ==
    ::  if game has no result
    :~
      notification-card
      position-update-card
    ==
    ::
    ::  finally, execute code
    [`[updated-game u.new-position] result-cards]
--

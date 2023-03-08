# Data Types

Chess’s data types are defined across two `/sur` files and at the top of the `/app` file.

## /sur/chess
Most types in `/sur/chess` come with a default value ([“bunt”](https://developers.urbit.org/reference/glossary/bunt)) specified with the [`$~`](https://developers.urbit.org/reference/hoon/rune/buc#-bucsig) rune, mostly for illustrative purposes. Only twice in the code is the bunt of any of these types actually used.

### chess-side
```
+$  chess-side
  $~  %white
  $?  %white
      %black
  ==
```

A chess player can have one of two `chess-side`s: white or black.

### chess-piece-type
```
+$  chess-piece-type
  $~  %pawn
  $?  %pawn
      %knight
      %bishop
      %rook
      %queen
      %king
  ==
```

A chess piece can have one of six `chess-piece-type`s.

### chess-promotion
```
+$  chess-promotion
  $~  %queen
  $?  %knight
      %bishop
      %rook
      %queen
  ==
```

A pawn can be promoted to one of four `chess-piece-type`s.

### chess-piece
```
$~  [%white %pawn]
  $:  chess-side
      chess-piece-type
  ==
```

A `chess-piece` is a cell of the piece’s `chess-side` and `chess-piece-type`.

### chess-rank
```
+$  chess-rank
  $~  %1
  ?(%1 %2 %3 %4 %5 %6 %7 %8)
```

A chessboard has eight rows (“ranks”), numbered with literals `%1` to `%8`.

### chess-file
```
+$  chess-file
  $~  %a
  ?(%a %b %c %d %e %f %g %h)
```

A chessboard has eight columns (“files”), labelled with terms `%a` to `%h`.

### chess-square
```
+$  chess-square
  $~  [%a %1]
  [chess-file chess-rank]
```

A `chess-square` is a cell of `chess-rank` and `chess-file`.

### chess-traverser
```
+$  chess-traverser
  $-(chess-square (unit chess-square))
```

A `chess-traverser` is a gate which takes a `chess-square` as input, and returns a `chess-square` or null. This is used to prevent chess pieces from moving off the board, whose bounds we defined with `chess-rank` and `chess-file`.

### chess-board
```
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
```

A `chess-board` is just a `map` of `chess-square`s and `chess-piece`s.

The bunt of `chess-board` is the starting position of a standard chess game; this is defined once, here, and can be invoked whenever you need to start a game.

### chess-piece-on-square
```
+$  chess-piece-on-square
  [square=chess-square piece=chess-piece]
```

The `chess-piece-on-square` type helps us deal with key-value pairs in the `chess-board`.

### chess-castle
```
+$  chess-castle
  $~  %both
  $?  %both
      %queenside
      %kingside
      %none
  ==
```

We use `chess-castle` to present the options available to a player at any given move: could they do a queenside castle, kingside, both, or none?

### chess-position
```
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
```

A `chess-position` is the current position in a game, and includes the following information:

* `board`: A `chess-board` holding the current position.
* `player-to-move`: The `chess-side` whose turn it is to move.
* `white-can-castle`: The `chess-castle` options for white.
* `black-can-castle`: The `chess-castle` options for black.
* `en-passant`: The position of an en passant pawn, if one exists.
* `ply-50-move-rule`: If this reaches 50, the [fifty-move rule](https://en.wikipedia.org/wiki/Fifty-move_rule) is invoked.
* `move-number`: The number of moves in this game. This is just metadata used to populate `chess-fen`s.

### chess-player
```
+$  chess-player
  $~  [%unknown ~]
  $%  [%name @t]
      [%ship @p]
      [%unknown ~]
  ==
```

A player’s name or `@p`. Only used to populate a game’s Portable Game Notation (PGN) data.

### chess-result
```
+$  chess-result
  $~  %'½–½'
  $?  %'1-0'
      %'0-1'
      %'½–½'
  ==
```

A game’s result is a win, loss, or draw, recorded in the `chess-game` type.

### chess-move
```
+$  chess-move
  $%  [%move from=chess-square to=chess-square into=(unit chess-promotion)]
      [%castle ?(%queenside %kingside)]
  ==
```

A `chess-move` is one of two types:

* A regular move from one square to another.
* A queen- or king-side castle.

### chess-fen
```
+$  chess-fen  @t
```

A `chess-fen` is a chess position, recorded in Forsyth-Edwards Notation. This is used throughout the frontend and backend to work with positions.

### chess-san
```
+$  chess-san  @t
```

A `chess-san` is a chess move, recorded in Standard Algebraic Notation. This is only used to populate the Game Panel on the frontend.

### chess-game
```
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
    round=(unit (list @))
    white=chess-player
    black=chess-player
    result=(unit chess-result)
    moves=(list [chess-move chess-fen chess-san])
  ==
```

 A `chess-game` is an active or archived chess game. It has the following properties:

* `game-id`: The game’s unique ID, a `@dau`, explained below.
* `event`: The event description, used in challenges on the frontend and to populate the game’s PGN.
* `site`: Used to populate the game’s PGN. This is never used in code, its value is only ever `'Urbit Chess'`, and exists only for full compliance with the PGN standard.
* `date`: The date of the game.
* `round`: The round number, as if this were part of a tournament. Again, not actually used in code.
* `white`: The white player.
* `black`: The black player.
* `result`: The result of the game, if there is one.
* `moves`: A list of moves.

Note that the `moves` list isn’t a list of `chess-move`s, but a list of tuples of `[chess-move chess-fen chess-san]`. This tuple contains the move as a `chess-move`, the position that results from that move, and the move as a `chess-san`. Bundling this information together is convenient when we need to work with corresponding moves and positions.

A `@dau` is just a sub-type of `@da`, that replaces the sub-second values with random entropy. This ensures that every `game-id` is globally unique.

### chess-challenge
```
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
```

A `chess-challenge` is sent to prospective opponents, carrying the challenger’s `chess-side`, the `event` description, and a unit of the number of this `round`.

### chess-action
```
+$  chess-action
  $%  [%challenge who=ship challenge=chess-challenge]
      [%accept-game who=ship]
      [%decline-game who=ship]
      [%offer-draw game-id=@dau]
      [%accept-draw game-id=@dau]
      [%decline-draw game-id=@dau]
      [%change-special-draw-preference game-id=@dau setting=?]
      [%claim-special-draw game-id=@dau]
      [%move game-id=@dau move=chess-move]
      [%resign game-id=@dau]
      [%request-undo game-id=@dau]
      [%decline-undo game-id=@dau]
      [%accept-undo game-id=@dau]
  ==
```

The `chess-action` type union defines the acceptable `vase`s that the app’s `%chess-action` mark will accept.

### chess-update
```
+$  chess-update
  $%  [%challenge-sent who=ship challenge=chess-challenge]
      [%challenge-received who=ship challenge=chess-challenge]
      [%challenge-resolved who=ship]
      [%challenge-replied who=ship]
      [%position game-id=@dau position=@t san=@t special-draw-available=?]
      [%draw-offer game-id=@dau]
      [%draw-declined game-id=@dau]
      [%undo-declined game-id=@dau]
      [%undo-accepted game-id=@dau]
      [%undo-request game-id=@dau]
      [%result game-id=@dau result=chess-result]
      [%special-draw-preference game-id=@dau setting=?]
  ==
```

The `chess-update` type union defines all the possible values that a subscriber may receive as a `%fact` from the Chess agent.

### chess-rng
```
+$  chess-rng
  $%  [%commit p=@uvH]
      [%reveal p=@uvH]
  ==
```

The `%commit` and `%reveal` hashes are both unsigned, 256-bit, base32 integers. They’re used to allocate sides to the players in a game where the sides are randomized. See `%chess-rng` for more.

### chess-commitment
```
+$  chess-commitment
  $:  our-num=@uvH
      our-hash=@uvH
      her-num=(unit @uvH)
      her-hash=(unit @uvH)
      revealed=_|
  ==
```

The `chess-commitment` tuple stores numbers and hashes for both players. See `%chess-rng` for more.

### chess-game-result
```
+$  chess-game-result
  $:  game-id=@dau
      result=chess-result
      move=(unit chess-move)
  ==
```

A `chess-game-result` is a tuple of `game-id`, `chess-result`, and a unit of `chess-move`, used to de-vase a `%chess-game-result` sign.

## /sur/historic
The `/sur/historic.hoon` file contains the old versions of various pieces of app state, whose up-to-date versions are documented in the `/sur/chess` page. As of Chess 1.0 these aren’t really used in code, so we won’t go over them in detail.

A type `foo-0` would denote the type `foo` as it existed in `state-0`, `foo-1` as used in `state-1`, etc.

### active-game-state-0
```
+$  active-game-state-0
  $:  game=chess-game-0
      position=chess-position
      ready=?
      sent-draw-offer=?
      got-draw-offer=?
  ==
```

### state-0
```
+$  state-0
  $:  %0
      games=(map @dau active-game-state-0)
      archive=(map @dau chess-game-0)
      challenges-sent=(map ship chess-challenge)
      challenges-received=(map ship chess-challenge)
      rng-state=(map ship chess-commitment)
  ==
```

### chess-move-0
```
+$  chess-move-0
   $~  [%end %'½–½']
   $%  [%move from=chess-square to=chess-square into=(unit chess-promotion)]
       [%castle ?(%queenside %kingside)]
       [%end chess-result]
   ==
```

### chess-game-0
```
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
```

### chess-action-0
```
+$  chess-action-0
  $%  [%challenge who=ship challenge=chess-challenge]
      [%accept-game who=ship]
      [%decline-game who=ship]
      [%offer-draw game-id=@dau]
      [%accept-draw game-id=@dau]
      [%decline-draw game-id=@dau]
      [%move game-id=@dau move=chess-move-0]
  ==
```

### chess-update-0
```
+$  chess-update-0
  $%  [%challenge who=ship challenge=chess-challenge]
      [%position game-id=@dau position=@t]
      [%result game-id=@dau result=chess-result]
      [%draw-offer game-id=@dau]
      [%draw-declined game-id=@dau]
  ==
```

## App State
The current app state is `state-1`, which contains among other things the `active-game-state` of each active game.

### active-game-state
```
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
```

The `active-game-state` contains the following information about active games:

* `game`: The `chess-game`, which is all that will exist of this game once it’s been archived.
* `position`: The current `chess-position`.
* `fen-repetition`: XX
* `special-draw-available`: Whether or not a player could invoke a “special draw” such as the 50-move rule.
* `ready`: XX
* `sent-draw-offer`: Whether or not you have sent a draw offer regarding this game.
* `got-draw-offer`: Whether or not you have received a draw offer regarding this game.
* `auto-claim-special-draws`: Whether or not you’d like to automatically invoke special draws like the 50-move rule; toggled from the frontend.
* `sent-undo-request`: Whether or not you’ve requested to undo the last move.
* `got-undo-request`: Whether or not you’ve received a request to undo the last move.

### state-1
```
+$  state-1
  $:  %1
      games=(map @dau active-game-state)
      archive=(map @dau chess-game)
      challenges-sent=(map ship chess-challenge)
      challenges-received=(map ship chess-challenge)
      rng-state=(map ship chess-commitment)
  ==
```

`state-1` contains the entire app state for Chess:

* `games`: All active games.
* `archive`: All archived games, whether they were completed with a win/loss, a draw, or a resignation.
* `challenges-sent`: Pending challenges you’ve sent.
* `challenges-received`: Pending challenges you’ve received.
* `rng-state`: The `chess-commitment`s you’ve received from opponents.

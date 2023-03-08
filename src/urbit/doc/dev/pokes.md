# Pokes

Chess has four marks:
* `%chess-action`: Most actions.
* `%chess-challenge`: Challenging another player.
* `%chess-decline-challenge`: Declining a challenge.
* `%chess-rng`: Accepting challenges where the sides are randomized.

## %chess-action
### %challenge
```
[%challenge who=ship challenge=chess-challenge]
```

Send a challenge to another ship.

Will error if you’ve already sent them a challenge.

### %accept-game
```
[%accept-game who=ship]
```

Accept the challenge from a specified player. This will create a new game, send it to the opponent, and subscribe to updates on the opponent’s instance of this game.

Will error if you’ve not received a challenge from the specified ship.

### %decline-game
```
[%decline-game who=ship]
```

Decline a challenge, and tell the challenger that you’ve declined.

Will error if there’s no challenge from the specified ship.

### %change-special-draw-preferences
```
[%change-special-draw-preference game-id=@dau setting=?]
```

Toggle the `special-draw-preference` for this game.

Will error if there’s no active game with the specified `game-id`.

### %offer-draw
```
[%offer-draw game-id=@dau]
```

Offer a draw to your opponent in this game.

Will error if there’s no active game with the specified `game-id`.

### %accept-draw
```
[%accept-draw game-id=@dau]
```

Accept a draw offer, archive the game, and kick all subscribers to updates on this game.

Will error if there’s no active game matching the specified `game-id`, or if there’s no draw offer to accept for that game.

### %decline-draw
```
[%decline-draw game-id=@dau]
```

Decline a draw offer.

Will error if there’s no active game matching the specified `game-id`, or if there’s no draw offer to decline for that game.


### %claim-special-draw
```
[%claim-special-draw game-id=@dau]
```

Claim a special draw such as the 50-move-rule, archive the game, and kick all subscribers to updates on this game.

Will error if there’s no active game matching the specified `game-id`, if it’s not your turn, or if there’s no special draw available for this game.


### %move
```
[%move game-id=@dau move=chess-move]
```

Make a move. If this move ends the game archive it.

Will error if there’s no active game matching the specified `game-id`, if the opponent hasn’t subscribed to this game yet, if it’s not actually your move, or if the move is illegal.


### %resign
```
[%resign game-id=@dau]
```

Resign from a game, adding 

Will error if there’s no active game matching the specified `game-id`.

### %request-undo
```
[%request-undo game-id=@dau]
```

Send a request to your opponent to undo the last move, record that you’ve sent an undo request.

Will error if there’s no active game matching the specified `game-id`.

### %decline-undo
```
[%decline-undo game-id=@dau]
```

Decline your opponent’s undo request.

Will error if there’s no active game matching the specified `game-id`, or if there’s no undo request to decline for that game.

### %accept-undo
```
[%accept-undo game-id=@dau]
```

Accept your opponent’s undo request.

## %chess-challenge
Receive an incoming challenge and put them in the `challenges-received` map.

## %chess-decline-challenge
Decline an incoming challenge and remove it from the `challenges-received` map.

## %chess-rng
This poke accepts `chess-rng`s, which are either tagged with `%commit` or `%reveal`.

### %commit
If you’re sending a challenge, set an `our-num` and `our-hash` and send it to the opponent. Additionally, add it to the `rng-state`  entry for this challenge.

If you’re accepting a challenge, add your `num` and `hash` to the shared `commitment`, then send the completed version back to the challenger.

### %reveal
If you’re sending a challenge, send the final `commitment` to your opponent.

If you’re accepting a challenge, check that the `commitment` is in order and send your challenger a new game.

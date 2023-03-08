# Scry Endpoints

Chess offers a few scry paths, mostly related to games and challenges and mostly used by the frontend to fetch data. Eventually, [all app state should be scryable](https://github.com/thecommons-urbit/chess/issues/71).

## %x
### /game
`.^(noun %gx /=chess=/game/~1996.2.16..10.00.00..0000/noun)`

Get all `chess-game` info for a specific game, whether in active `games` or the `archive`.

### /challenges/outgoing
`.^(noun %gx /=chess=/challenges/outgoing/noun)`

List all outgoing challenges.

### /challenges/incoming
`.^(noun %gx /=chess=/challenges/incoming/noun)`

List all incoming challenges.

### /friends
```
.^(noun %gx /=chess=/friends/noun)
.^(json %gx /=chess=/friends/json)
```

List all “friends” of this ship, who will be displayed in the frontend’s Friends menu. Currently your “friends” are your mutual pals in the %pals app, but this is subject to change as Urbit’s social graph tooling evolves.

## %y
### /games
`.^(arch %gy /=chess=/games)`

List all `game-id`s stored on this ship, whether in active `games` or the `archive`.

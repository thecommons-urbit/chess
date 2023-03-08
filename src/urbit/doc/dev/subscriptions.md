# Subscription paths

Chess’s subscription paths are used to update the frontend, but `/moves` and `/updates` could be used by other agents to monitor games.

## /challenges
`[%challenges ~]`

Get updates on incoming and outgoing challenges. Private.

## /active-games
` [%active-games ~]`

Get all active games and receive new ones when challenges are accepted. Private.

## /moves
`[%game @ta %moves ~]`

Start a new game, inform the opponent about it, tell our frontend the challenge was accepted, and subscribe to moves from this game. [This should be simplified](https://github.com/thecommons-urbit/chess/issues/70).

This path is technically public, but only to you and a prospective opponent with whom you’ve exchanged a challenge.

## /updates
`[%game @ta %updates ~]`

Get all `chess-update`s on an active game.

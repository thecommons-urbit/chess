/+  chess
=,  chess
=,  format
=,  mimes:html
|_  pgn=wain
++  grab
  |%
  ++  noun  wain
  ++  mime  |=((pair mite octs) (to-wain q.q))
  ++  chess-game  to-pgn
  --
++  grow
  |%
  ++  noun  pgn
  ++  mime
    [/application/'vnd.chess-pgn' (as-octs (of-wain pgn))]
  --
++  grad  %txt
--

/-  *chess
/+  chess
=,  format
|_  archive=chess-archive
++  grab
  |%
  ++  noun  chess-archive
  --
++  grow
  |%
  ++  noun  archive
  ++  json
    %-  frond:enjs
    :-  'localArchive'
    :-  %a  (turn (tap:arch-orm archive) archive-json:chess)
  --
++  grad  %noun
--


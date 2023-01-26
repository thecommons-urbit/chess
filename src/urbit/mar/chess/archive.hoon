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
    :-  %a  (turn ~(val by archive) archive-json:chess)
  --
++  grad  %noun
--


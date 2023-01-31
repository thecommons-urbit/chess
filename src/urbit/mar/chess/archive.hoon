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
    ::  XX: convert for archive mop
    ::      (tap:arch-orm archive) produces (list item)
    ::      not a pure list of values?
    ::      (turn list gate)
    ::      can I convert the archive-json gate to only
    ::      grab the (+) tail of each pair in the list?
    ::  :-  %a  (turn ~(val by archive) archive-json:chess)
    :-  %a  (turn ~(tap:arch-orm archive) archive-json:chess)
  --
++  grad  %noun
--


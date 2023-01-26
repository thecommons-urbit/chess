/-  chess
=,  format
|_  moves=wain
++  grab
  |%
  ++  noun  wain
  --
::
::  going to frontend en:js form
++  grow
  |%
  ++  noun  moves
  ++  json
    %-  frond:enjs
    :-  'moves'
    :: an array
    :-  %a
    :: turn the different lines of a
    :: wain into an entry of %s string
    :: for the array.
    ::
    ::  turn([list gate])
    %+  turn  moves
    :: will I need (of-wain move)
    |=(move=@t [%s move])
  --
++  grad  %txt
--

# Urbit Chess

This is an experimental Urbit app which allows you to use your ship to play Chess with others.

The original `%chess` was made by Raymond E. Pasco for several reasons:
- To practice Hoon
- As a hobby project
- As a proof-of-concept that users could share software between ships using Urbit "desks"

Ray paused work on `%chess` in March 2021 due to personal reasons. In August 2021, Tlon released full-fledged software
distribution in an update to Arvo.

Continuing the `%chess` app's history as a proof-of-concept sandbox, I (Alex Shelkovnykov) updated it to work with the
software distribution update as a broadly-visible example in time for Assembly 2021.

The `%chess` app has several minor gameplay bugs and one major one. Neither of the developers who worked on it had any
frontend experience, as is immediately noticeable from its dated appearance. It is debatable whether `%chess` was even
implemented "the right way" (e.g. by replicating Chess logic in Hoon, as opposed to transmitting board states between
JavaScript apps using the Gall vane).

It is my opinion that this app should be treated as an interactive, experimental, proof-of-concept Urbit application:
nothing more. Raymond E. Pasco may feel differently, and is entitled to do so as the one who wrote the overwhelming
majority of this code.

You can find his original repository for Urbit Chess [here](https://git.sr.ht/~ray/urbit-chess) and his Urbit Chess
Announcements page [here](https://lists.sr.ht/~ray).

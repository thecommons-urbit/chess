# `%chess`

![Urbit Chess Demo](https://raw.githubusercontent.com/ashelkovnykov/urbit-chess/master/images/urbit-chess-demo.png)

## About

`%chess` is an [Urbit](https://urbit.org) app which allows you to play correspondence Chess with other Urbit users. It
is a fully-decentralized, peer-to-peer Chess application.

The original `%chess` was made by Raymond E. Pasco for several reasons:

- To practice Hoon
- As a hobby project
- As a proof-of-concept that users could share software between ships using Urbit "desks"

Ray paused work on `%chess` in March 2021 due to personal reasons. In August 2021, Tlon released full-fledged software
distribution in an update to Arvo. I updated `%chess` to work with this update as a broadly-visible example of app
distribution for Assembly 2021.

In my opinion, `%chess` is an experimental, community sandbox to show what's possible with Urbit. As Urbit evolves, so
too should `%chess`. Ray may feel differently, and is entitled to do so as the original creator of the app (as of today,
he is still the developer of all the Hoon code).

You can find his original repository for Urbit Chess [here](https://git.sr.ht/~ray/urbit-chess) and his Urbit Chess
Announcements page [here](https://lists.sr.ht/~ray).

## News

The interface has been completely overhauled - `%chess` no longer looks like it's from 1992!
Chess game is a **simulation** of real life challenges.
Hence a mobile version of the game should be well structured.

## Installation

You can find `%chess` on Urbit using the App Search in Grid. Search for `~finmep-lanteb` (my ship) and you should see
`%chess` as an available app.

![Urbit Chess Grid View](https://raw.githubusercontent.com/ashelkovnykov/urbit-chess/master/images/urbit-chess-find.png)

## Development

Below is a step-by-step guide for developing `%chess` and testing changes. This section assumes at least minor Urbit
development experience, i.e.:

- familiarity with Linux
- familiarity with git
- completion of at least some (preferably all) of
  [Hoon School](https://developers.urbit.org/guides/core/hoon-school/A-intro) and
  [App School](https://developers.urbit.org/guides/core/app-school/intro)

The above is not to say that people with no prior development experience are barred from contributing, just that this is
not a place to receive guided help. There are plenty of issues with `%chess` that need fixing, many of which are simple
and would be good "first-time" Urbit contributions.

### 0. Setup your development environment

#### Urbit binaries

See [this guide](https://developers.urbit.org/guides/core/environment) on the Urbit developers portal for information on
how to get the Urbit binaries and what sort of software may be useful for developing Urbit applications.

#### Urbit sources

Testing the app locally will require a copy of the Urbit source code:

```
git clone https://github.com/urbit/urbit.git
```

#### Docker

To spare your machine from the nightmare that is the JS development environment, `%chess` uses
[Docker](https://www.docker.com), so make sure that you have it [installed](https://docs.docker.com/engine/install/)
and that your user account has `sudo` privileges.

NOTE: [Do not use the 'docker' group](https://fosterelli.co/privilege-escalation-via-docker.html)

### 1. Pull a copy of the `%chess` code

```
git clone https://github.com/ashelkovnykov/urbit-chess.git
```

### 2. Do development stuff

Check out my [IDEA Hoon plugin](https://github.com/ashelkovnykov/idea-hoon-plugin) if you want to work on Hoon in a
fully-fledged IDE, instead of vim/emacs/VSC!

### 3. Setup test ship

Create a development ship of your choice:

```
./urbit -F zod
```

Create a `%chess` desk from inside your dev ship:

```
|merge %chess our %base
```

Mount the `%chess` desk, so that we can push our updated code to it:

```
|mount %chess
```

### 4. Build `%chess` code

Run the provided build script to compile the `%chess` frontend. Substitute the name of your dev ship using the `-s`
option:

```
./bin/build.sh -s zod
```

### 5. Install the `%chess` app

Clear the default files from cloning the `%base` desk:

```
rm -rf ../Urbit/zod/chess/*
```

Push the core desk files to the `%chess` app on the dev ship:

```
cp -rfL ~/[path to urbit source code]/urbit/pkg/base-dev/* ../Urbit/zod/chess/
cp -rfL ~/[path to urbit source code]/urbit/pkg/garden-dev/* ../Urbit/zod/chess/
```

Run the provided installation script to copy the `%chess` backend files to the dev ship. Substitute the path to the pier
using the `-p` option and the dev ship name using the `-s` option:

```
./bin/install.sh -p /home/user/Urbit -s zod
```

Commit the changes from inside your dev ship:

```
|commit %chess
```

The dev ship is now awaiting the frontend files to link to the app. Installation is not complete until these files are
provided.

Login to your dev ship through your browser (the URL at which the ship's interface is running is posted on launch; it
should look something like `http://localhost:8081`). Navigate to the docket glob interface (e.g.
`http://localhost:8081/docket/upload`). Follow the instructions on this page to upload the frontend files to your dev
ship. Once globbing is completed, you can return to the main page for your dev ship and see that the Chess app is
installed.

#### NOTE: About browsers

Google Chrome and Chromium based browsers have a tough time clearing the cache and picking up changes made to the
frontend. If you're developing the frontend, it's recommended to use Firefox for testing.

### 6. Testing with other ships

Once installed, you need to publish `%chess` so that other dev ships on your computer will be able to find it:

```
:treaty|publish %chess
```

Now, any additional dev ships on your computer will be able to install `%chess` through Grid, just like they would if
they were real ships. You can launch multiple test ships to communicate with each other and/or your dev ship to test
the `%chess` Hoon and network functionality.

#### NOTE: About fake-ships

Fake-ships hosted on the same computer can talk to each other, but they still have 'realistic' packet routing. This
means that fake galaxies can talk to each other, but fake planets cannot, unless they have appropriate fake stars and
fake galaxies also active on the computer to route for them. Examples:

```
~tex & ~mex:            GOOD
~tex & ~bintex:         GOOD
~mex & ~bintex:         BAD
~tex, ~mex, & ~bintex:  GOOD
```

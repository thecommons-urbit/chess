# `%chess`

![Urbit Chess Demo](https://raw.githubusercontent.com/ashelkovnykov/urbit-chess/master/images/urbit-chess-demo.png)

## About

`%chess` is an [Urbit](https://urbit.org) app which allows you to play chess with other Urbit users. It is a
fully-decentralized, peer-to-peer chess application.

The original `%chess` was made by Raymond E. Pasco for several reasons:
- To practice Hoon
- As a hobby project
- As a proof-of-concept that users could share software between ships using Urbit "desks"
You can find his original repository for Urbit Chess [here](https://git.sr.ht/~ray/urbit-chess) and his Urbit Chess
Announcements page [here](https://lists.sr.ht/~ray).

Ray paused work on `%chess` in March 2021 due to personal reasons. In August 2021, Tlon released full-fledged software
distribution in an update to Arvo. `~finmep-lanteb` updated `%chess` to work with this update as a broadly-visible
example of app distribution for Assembly 2021.

`%chess` is a community sandbox for Urbit apps. As Urbit evolves, so too should `%chess`. `%chess` should seek to at all
times incorporate the most modern Urbit programming techniques. It should also strive to provide well-documented, clear,
concise code that beginner Hoon coders can use as a reference.

## News

The [Chess Improvements Bounty](https://urbit.org/grants/chess-bounty) has been posted and filled.

## Installation

You can find `%chess` on Urbit using the App Search in Grid. Search for `~finmep-lanteb` and you should see
`%chess` as an available app.

Alternatively, you can install from your ship's Terminal:
```
|install ~finmep-lanteb %chess
```

## Development

Below is a step-by-step guide for developing `%chess` and testing changes. This section assumes at least minor Urbit
development experience, i.e.:
- familiarity with Unix-based systems
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

#### Docker & Webpack

To spare you from the nightmare that is the JS development environment, `%chess`'s build script is equipped to use
[Docker](https://www.docker.com); if you'd like to use Docker, make sure that you have it [installed](https://docs.docker.com/engine/install/)
and that your user account on your machine has `sudo` privileges.

(NOTE: [Do not use the 'docker' group](https://fosterelli.co/privilege-escalation-via-docker.html).)

If you are already in the nightmare that is the JS development environment, and cannot wake up, you can build `%chess`
natively with [Webpack](https://webpack.js.org). This has the benefit of being \~95x faster than the Docker build,
just a few seconds, but at what cost?

This guide will cover both workflows regardless. For the Webpack build, we only assume you have [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
installed already.

### 1. Pull a copy of the `%chess` code

```
git clone https://github.com/ashelkovnykov/urbit-chess.git
```

### 2. Do development stuff

Check out the [IDEA Hoon plugin](https://github.com/ashelkovnykov/idea-hoon-plugin) if you want to work on Hoon in a
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

Run the provided build script from `/urbit-chess` to compile the `%chess` frontend.

To run the Docker build, substitute the name of your dev ship using the `-s`
option:
```
./bin/build.sh -s zod
```

To run the Webpack build you'll need to install Webpack and htmlWebpackPlugin if you don't have them already. `cd` to
`/src/frontend` and install Webpack and [htmlWebpackPlugin](https://webpack.js.org/plugins/html-webpack-plugin/):
```
npm install --save-dev webpack
npm install --save-dev html-webpack-plugin
```

(The `--save-dev` flag keeps `%chess`'s dependency list clean for our collaborators using Docker.)

To run the build script with Webpack, add an `-n` flag like so:
```
./bin/build.sh -s zod -n
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
using the `-p` option and your pier's name using the `-s` option:
```
./bin/install.sh -p /home/user/Urbit -s zod
```

Commit the changes from inside your dev ship:
```
|commit %chess
```

The dev ship is now awaiting the frontend files to link to the app. Installation is not complete until these files are
provided.

Before you can link your frontend, you'll need to install your app if you haven't already:
```
|install our %chess
```

Login to your dev ship through your browser (the URL at which the ship's interface is running is posted on launch; it
should look something like `http://localhost:8081`). Navigate to the docket glob interface (e.g.
`http://localhost:8081/docket/upload`). Follow the instructions on this page to upload the frontend files to your dev
ship.

Once globbing is completed, you can return to the main page for your dev ship and see that the Chess app is installed.

#### NOTE: About browsers

Google Chrome and Chromium-based browsers have a tough time clearing the cache and picking up changes made to the
frontend. If you're developing the frontend, it's recommended to use Firefox for testing.

### 6. Testing with other ships

Once installed, you need to publish `%chess` so that other dev ships on your computer will be able to find it:
```
:treaty|publish %chess
```

Now, any additional dev ships on your computer will be able to install `%chess` through Grid,
just like they would if they were real ships:
```
|install ~zod %chess
```

You can launch multiple test ships to communicate with each other and/or your dev ship to test
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

## Contributors

Appearing in alphabetical order of `@p`:

- `~bonbud-macryg` - [@bonbud-macryg](https://github.com/bonbud-macryg)
- `~datder-sonnet` - Tom Holford, [@tomholford](https://github.com/tomholford)
- `~finmep-lanteb` - Alex Shelkovnykov, [@ashelkovnykov](https://github.com/ashelkovnykov), `~walbex`
- `~nordus-mocwyl` - [@brbenji](https://github.com/brbenji)
- `~rovmug-ticfyn` - [@rovmug-ticfyn](https://github.com/rovmug-ticfyn)
- `~sigryn-habrex` - [Raymond E. Pasco](https://ameretat.dev)

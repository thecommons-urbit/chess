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

In September, 2022, `~bonbud-macryg`, `~nordus-mocwyl`, and `~rovmug-ticfyn` began working on `%chess` in their spare
time for an [Urbit Foundation bounty](https://urbit.org/grants/chess-bounty), which they completed in September, 2023.

## Mission

`%chess` seeks to be a community sandbox for Urbit apps. As Urbit evolves, so too should `%chess`. `%chess` should seek
at all times to incorporate the most modern Urbit programming techniques. It should strive to provide well-documented,
clear, concise code that beginner Hoon coders can use as a reference.

Whether or not `%chess` meets all of these goals at any particular moment, they are the aspirations of the repo.

## News

The "Chess Improvements Bounty" has been completed. Pharaoh has set the chess slaves free!

![go now be free](https://0x0.st/HV0I.png)

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

#### Docker & Vite

To spare you from the nightmare that is the JS development environment, `%chess`'s build script is equipped to use
[Docker](https://www.docker.com). If you'd like to use Docker, make sure that you have it
[installed](https://docs.docker.com/engine/install/) and that your user account on your machine has `sudo` privileges.

(NOTE: [Do not use the 'docker' group](https://fosterelli.co/privilege-escalation-via-docker.html).)

If you are already in the nightmare that is the JS development environment, and cannot wake up, you can build `%chess`
natively with [Vite](https://vitejs.dev/).

This guide will cover both workflows. For the native Vite build, we only assume you have
[npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) installed already.

### 1. Pull a copy of the `%chess` code

```
git clone https://github.com/ashelkovnykov/urbit-chess.git
```

### 2. Do development stuff

Check out the [IDEA Hoon plugin](https://github.com/ashelkovnykov/idea-hoon-plugin) if you want to work on Hoon with
advanced language support!

### 3. Setup test ship

Create a development ship of your choice:
```
./urbit -F zod
```

Create a `%chess` desk from inside your dev ship:
```
|new-desk %chess
```

Mount the `%chess` desk, so that we can push our updated code to it:
```
|mount %chess
```

### 4. Build `%chess` code

Run the provided build script from `/urbit-chess` to compile the `%chess` frontend.

#### Docker build

To run the Docker build, substitute the name of your dev ship using the `-s` option:
```
./bin/build.sh -s zod
```

#### Vite build

To run the build script without Docker, add an `-n` flag like so:
```
./bin/build.sh -s zod -n
```

### 5. Install the `%chess` app

Run the provided installation script to copy the `%chess` backend files to the dev ship. Substitute the path to the pier
using the `-p` option and your pier's name using the `-s` option:
```
./bin/install.sh -p /home/user/Urbit/test-piers -s zod
```

Commit the changes from inside your dev ship:
```
|commit %chess
```

Next, tell the fake ship to install the app:
```
|install our %chess
```
This is only necessary the first time you install `%chess` on a fake ship. If you're updating the files on a ship which
already has `%chess` installed, just committing the new files is enough.

#### Globbing the frontend

The dev ship is now awaiting the frontend files to link to the app. Installation is not complete until these files are
provided. Login to your dev ship through your browser (the URL at which the ship's interface is running is posted on
launch; it should look something like `http://localhost:8080`). Navigate to the docket glob interface (e.g.
`http://localhost:8080/docket/upload`). Follow the instructions on the page to upload the frontend files to your dev
ship.

Once globbing is completed, you can return to Landscape on the dev ship and see that `%chess` is installed.

#### Testing the frontend

You can use Vite to test changes to the frontend as soon as you save those changes in your editor. Run your fakeship at `localhost:8080` and run `npm run dev` in the `/src/frontend` folder, then open `localhost:5173/apps/chess` in any browser in which you're logged into the fakeship.

You may need to run the following commands in your fakeship's Dojo for it to accept requests from Vite.
```
> |cors-approve 'http://localhost:5173'
> |cors-approve 'http://localhost:8080'
```

#### NOTE: About browsers

Google Chrome and Chromium-based browsers have a tough time clearing the cache and picking up changes made to the
frontend. If you're developing the frontend, it's recommended to use Firefox for final testing.

### 6. Testing with other ships

Once installed, you need to publish `%chess` so that other dev ships on your computer will be able to find it:
```
:treaty|publish %chess
```

Now, any other fake ships running on your computer will be able to install `%chess` through Landscape, just like they
would on the real network. Usually, though, it's more convenient to have them install through the command line:
```
|install ~zod %chess
```

## Contributors

Appearing in alphabetical order of `@p`:

- `~bonbud-macryg` - [@bonbud-macryg](https://github.com/bonbud-macryg)
- `~datder-sonnet` - Tom Holford, [@tomholford](https://github.com/tomholford)
- `~finmep-lanteb` - Alex Shelkovnykov, [@ashelkovnykov](https://github.com/ashelkovnykov), `~walbex`
- `~nordus-mocwyl` - [@brbenji](https://github.com/brbenji)
- `~rovmug-ticfyn` - [@rovmug-ticfyn](https://github.com/rovmug-ticfyn)
- `~sigryn-habrex` - [Raymond E. Pasco](https://ameretat.dev)

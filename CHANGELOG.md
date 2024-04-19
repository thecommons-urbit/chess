# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.0] - 2022-07-21
### Added
- Practice board
- Move selection and verification using [chess.js](https://github.com/jhlywa/chess.js)
### Changed
- Massively overhauled interface using [Chessground](https://github.com/lichess-org/chessground)
- Switched to GPL3 license
### Fixed
- App frontend now closes connections to `chess` agent on page unload
- Made code compliant with licenses of all dependencies
- Changed build script to discourage using 'docker' group, which can be used for a privilege escalation attack

## 0.8.1 - 2021-10-15
### Added
- Dockerfile for building frontend JS using Docker
- Build/install scripts for adding Chess to Grid
- Changelog
### Changed
- App frontend
- Source code directory structure
- GNU make commands

## 0.7.2 - 2021-03-14
- Last commit made by Raymond E. Pasco, Initial commit for `%chess` Urbit app

[0.9.0]: https://github.com/ashelkovnykov/urbit-chess/compare/60a2345eabee12dba84f220408b13ff7917a1c8e...v0.9.0

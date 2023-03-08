# Interface

## Navigation
The Chess UI consists of three main sections:
* Game Panel: Information and controls for the game you’re currently viewing.
* Chessboard: Either the game you’re currently viewing, or the practice board.
* Control Panel: Information and controls for the Chess app.

## Game Panel
The Game Panel is where you can manage the active game you’re currently playing, or look through the archived game you’re viewing. From here you can:
* View previous positions
* Switch to the practice board
* Ask to undo a move
* Offer a draw
* Resign

### View Previous Positions
To review a previous position in a game, click on its corresponding move in the Game Panel. If you’re reviewing a previous position in an active game and receive a move from your opponent, the UI will reset to show you the game’s new position.

## Chessboard
Chess uses chessground to run the chessboard on the frontend, so LiChess players will feel right at home. You only have two ways to interact with the board:
* Left-click to move pieces.
* Right-click to draw on the board. Use CTRL+ALT+SHIFT / CMD+OPT+SHIFT to draw with different colours. Left-click anywhere to dismiss your drawings.

## Control Panel
The Control Panel has three tabs:
* Games: Browse active and archived games
* Challenges: Manage incoming and outgoing challenges
* Settings: Adjust settings concerning Chess’s visuals and gameplay, and manage your data

## Settings
In the Settings menu you can customize visual and gameplay settings, and manage your Chess data.

### Display Settings
To customize the look of your chess games, select any combination of chessboard and chesspieces in the Display settings.

### Gameplay Settings
The Gameplay settings let you make several decisions about how you want chess games to play out.

* **Auto Accept Special Draws:** When active, the [fifty-move-rule](https://en.wikipedia.org/wiki/Fifty-move_rule) and [threefold repetition rule](https://en.wikipedia.org/wiki/Threefold_repetition) are automatically enforced. If your opponent’s move creates one of these scenarios, your Chess agent will automatically end the game in a draw. Otherwise, you’ll be prompted to accept or reject these draws in a popup.

### Data Settings
XX

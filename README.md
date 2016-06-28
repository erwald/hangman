# Hangman

A hangman implementation using Phoenix channels.

To start the app:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## The code

The following files may be of interest:

  * `hangman.ex`, which defines the actual application and creates the supervision tree.
  * `game.ex`, which contains most of the game logic.
  * `game_server.ex`, which contains and handles the game state.
  * `game_channel.ex`, the channel, which handles the communication with the clients.
  * `socket.js`, the client, which handles communication with the game server (via the channel).

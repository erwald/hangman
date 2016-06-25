// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("games:1", {})
let gameStateContainer = $("#game-state")
let gameInput = $("#game-input")
let gameLogContainer = $("#game-log")

gameInput.on("keypress", event => {
  if (event.keyCode === 13) { // Pressed enter.
    let key = gameInput.val()
    if (/[a-zA-Z]/.test(key)) { // Single alphabetical character.
      channel.push("new:guess", {letter: key})
      gameInput.val("")
    }
  }
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("new:guess", msg => {
  var messageForUser = ""
  switch (msg.result) {
    case "finished":
      messageForUser = `Somebody tried to make a guess, but the game was already over.`
      break;
    case "duplicate":
      messageForUser = `Somebody tried to guess ${msg.letter}, but it had already been made.`
      break;
    case "too_soon":
      messageForUser = `Somebody wanted to guess ${msg.letter}, but it was too soon after the previous guess.`
      break;
    case "ok":
      messageForUser = `<b>Somebody guessed ${msg.letter}.</b>`
      break;
  }
  gameLogContainer.prepend(`<p>${messageForUser}</p>`)
})

channel.on("new:state", msg => {
  let phrase_string = msg.state.phrase.join('')
  let guesses = msg.state.guesses.join(', ')
  let remaining = msg.state.max_guesses - msg.state.guesses.length
  gameStateContainer.html(`<b>“${phrase_string}”</b>, with guesses: ${guesses} <em>(${remaining} remaining)</em>`)
})

export default socket

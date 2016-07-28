// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import Elm from './main'
import Player from './player'

const elmDiv = document.querySelector('#elm-target');

if (elmDiv) {
  const app = Elm.Main.embed(elmDiv);

  const player = Player(app.ports.playing.send)
  player.play()

  app.ports.play.subscribe(notes => {
    console.log('Will play', notes.map(n => n.letter))
    notes.forEach(player.queueNote)
  })
}

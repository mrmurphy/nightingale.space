# Nightingale.space

## Context

This is an experimental project, driven by a talk given at Elm-Conf US, 2016. Here'st the talk info:

This talk combines the power of Elm and Elixir’s Phoenix to turn Twitter into a platform for live
crowd-sourced music composition. We’ll cover Elm and Elixir channels, custom DSL parsing in Elm,
and driving the Web Audio API through Elm’s native inter-op abstraction: ports.

This talk aims to demonstrate the power of coordinating:

- Parser combinators, and Elm’s bogdanp/elm-combine library for transforming strings into data
- Elm’s standard application architecture
- Ports (Elm’s abstraction for interacting with its host language, in this case, Javascript)
- The Phoenix Web framework and its real-time channels
- Elm’s integration with Phoenix channels
- Tone.js for making music with the Web Audio API

For illustrative purposes we’ll suppose we are a consultancy, and a client has just approached us
with the need to turn tweets into music. She has come up with a compact musical notation that will
fit a good chunk of music into 140 characters, and she wants us to teach the browser to play the
music encoded in that notation. But that’s not all. Her vision includes a client that streams in
tweets, parsing them and queueing them up to be played as they happen, ultimately allowing users
to listen to a never-ending piece of real-time music, composed by a symphony of twitter users
world-wide.

## The Notation (Nightingale Notation)

The notation is as follows:

To play a note, the user types the following:

- A letter, optionally followed by a `+` (for a sharp), or a `-` (for a flat)
  or the _ character, to indicate a rest
- Optionally a letter defining the length of the note. If unspecified, "s" will be assumed.
  - t = 32nd note
  - s = 16th note
  - e = 8th note
  - q = Quarter note
  - h = Half note
  - w = Whole note
- Optionally a number, 0-8, defining the octave in which the note should be played, the default
  being 3

Any characters encountered between notes will be discarded.


Here's an example of "Twinkle, Twinkle, Little Star" written in Nightingale notation. In this
example, notes are separated by spaces, and bars by... bars. But that will all be ignored by the
parser. It's just there for the sake of readability.

```
Ce Ce Ge Ge | Ae Ae Ge _e | Fe Fe Ee Ee | De De Ce _e
Ge Ge Fe Fe | Ee Ee De _e | Ge Ge Fe Fe | Ee Ee De _e
Ce Ce Ge Ge | Ae Ae Ge _e | Fe Fe Ee Ee | De De Ce _e
```

And, in a more compact format:

```
CeCeGeGeAeAeGe_eFeFeEeEeDeDeCe_e
GeGeFeFeEeEeDe_eGeGeFeFeEeEeDe_e
CeCeGeGeAeAeGe_eFeFeEeEeDeDeCe_e
```

This structure can be captured with the following Regex:

```javascript
/([a-gA-G_]).*?([+-])?.*?([1-6])?.*?([0-8])?/
```

## The Decoding

A song is a list of notes, and a note looks like this:

```elm
type Accidental = Sharp | Flat

type alias Note =
  { letter : String
  , accidental : Maybe Accidental
  , octave : Int
  , length : Int
  , parseStart : Int
  , parseEnd : Int
  }
```

Which, when converted to JSON, would look like this:

```json
{
  "letter": "A",
  "accidental" : "sharp",
  "octave" : 3,
  "length" : 16,
  "parseStart" : 24,
  "parseEnd" : 25
}
```

## Generating music from the notes above:

An example of making Tone.js work how I want it to:
http://jsbin.com/faquwe/8/edit?js,console

This is a simple example of playing notes in Tone.js in a generative fashion, and firing a callback
when a particular note is being played. This is just a rough test that needs to be cleaned up
and revised.
```javascript
const notesMaster = [['+4n', 'C4'], ['+4n', 'E4'], ['+4n', null], ['+4n', 'G4'], ['+4n', 'C5']]

var notes = [...notesMaster]

function getNextNote() {
  if (notes.length === 0) {
    notes = [...notesMaster]
  }
  var note = notes.shift()
  return note
}

var synth = new Tone.Synth().toMaster();

var part = new Tone.Part(function(time, note){
	//the notes given as the second element in the array
	//will be passed in as the second argument
  console.log(note)
  if (note) {
    synth.triggerAttackRelease(note, time, time);
  } else {
    console.log('resting for ' + time)
    synth.triggerRelease()
  }
  const next = getNextNote()
  part.add(next[0], next[1]);
}, [0]).start(0);

Tone.Transport.start();
```

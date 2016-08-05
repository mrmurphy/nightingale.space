import Tone from 'tone'

const lengthLookup = {
  't': '32n',
  'T': '32n',
  's': '16n',
  'S': '16n',
  'e': '8n',
  'E': '8n',
  'q': '4n',
  'Q': '4n',
  'h': '2n',
  'H': '2n',
  'w': '1m',
  'W': '1m'
}

const accidentalLookup = {
  '+': '#',
  null: '',
  '-': 'b'
}

/**
 * noteToToneNote - Transforms an Elm Note into a tuple for playing in Tone: ['+4n', 'E4']
 *
 * @param  ElmNote note   A note having come through a port from Elm
 * @return [String, String]    A time and tone used to drive Tone.js
 */
function noteToToneNote(note) {
  if (!lengthLookup[note.length]) {
    console.log('got strange length', note.length, note)
  }
  const length = `+${lengthLookup[note.length] || '8n'}`
  const tone = `${note.letter}${accidentalLookup[note.accidental]}${note.octave}`
  return [length, tone]
}

export default function player(onPlayNote) {
  let queue = []

  const synth = new Tone.Synth().toMaster()

  const part = new Tone.Part(function(curTime, note){
    if (!note) {
      // Wait until notes come in to play them.
      let next = getNextNote()
      part.add('+32n', next)
      synth.triggerRelease()
      // Notify Elm that we're not playing a note now
      onPlayNote(null)
      return
    }

    // Notify Elm that we're playing a note now
    onPlayNote(note)
    const [length, tone] = noteToToneNote(note)
    if (note.letter !== '_') {
      console.log('triggering ', [tone, length]);
      synth.triggerAttackRelease(tone, length)
    } else {
      synth.triggerRelease()
    }
    let next = getNextNote()
    part.add(length, next)
  }, [0]).start(0)

  return {
    queueNote(note) {
      queue = queue.concat([note])
    },

    getNextNote,

    play() {
      Tone.Transport.start()
      Tone.Transport.bpm.value = 80
    },

    pause() {
      Tone.Transport.stop()
    }
  }

  function getNextNote() {
    const next = queue[0]
    queue = [...queue.slice(1)]
    return next
  }
}

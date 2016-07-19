module Parser exposing (..)

import Parser.Types exposing (Note(Note))


parseString str =
    Note
        { letter = "A"
        , accidental = Nothing
        , octave = 1
        , length = 4
        , parseStart = 2
        , parseEnd = 15
        }

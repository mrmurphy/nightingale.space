module Parser.Tests.SingleNote exposing (..)

import ElmTest exposing (..)
import Parser.Types exposing (Accidental(Sharp, Flat), Note(Note))
import Parser exposing (parseString)


allParts =
    ( "A+12"
    , Note
        { letter = "A"
        , accidental = Just Sharp
        , octave = 2
        , length = 1
        , parseStart = 0
        , parseEnd = 4
        }
    )


space =
    ( "_2"
    , Note
        { letter = "_"
        , accidental = Nothing
        , octave = 3
        , length = 2
        , parseStart = 0
        , parseEnd = 2
        }
    )


onlyAccidental =
    ( "A-"
    , Note
        { letter = "A"
        , accidental = Just Flat
        , octave = 3
        , length = 2
        , parseStart = 0
        , parseEnd = 2
        }
    )


onlyLength =
    ( "A6"
    , Note
        { letter = "A"
        , accidental = Nothing
        , octave = 3
        , length = 6
        , parseStart = 0
        , parseEnd = 2
        }
    )


lengthAndOctave =
    ( "A41"
    , Note
        { letter = "A"
        , accidental = Nothing
        , octave = 1
        , length = 4
        , parseStart = 0
        , parseEnd = 2
        }
    )


withIgnorables =
    ( "uAx4 uuuuggh 1"
    , Note
        { letter = "A"
        , accidental = Nothing
        , octave = 1
        , length = 4
        , parseStart = 2
        , parseEnd = 15
        }
    )


makeTest : String -> ( String, Note ) -> Test
makeTest name ( src, res ) =
    test name <| assertEqual (parseString src) res


tests : Test
tests =
    suite "A single note"
        [ makeTest "All parts" allParts
        , makeTest "With a space" space
        , makeTest "With only an accidental" onlyAccidental
        , makeTest "With only length" onlyLength
        , makeTest "With length and octave" lengthAndOctave
        , makeTest "With other characters" withIgnorables
        ]
module Note.Parser.Tests.SingleNote exposing (..)

import ElmTest exposing (..)
import Note exposing (Accidental(Sharp, Flat), Note(Note))
import Note.Parser exposing (notes)


allParts =
    ( "A+e2"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Just Sharp
            , octave = 2
            , length = "e"
            , parseStart = 0
            , parseEnd = 4
            }
      ]
    )


space =
    ( "_h"
    , [ Note
            { tweetId = 0
            , letter = "_"
            , accidental = Nothing
            , octave = 3
            , length = "h"
            , parseStart = 0
            , parseEnd = 2
            }
      ]
    )


onlyAccidental =
    ( "A-"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Just Flat
            , octave = 3
            , length = "s"
            , parseStart = 0
            , parseEnd = 2
            }
      ]
    )


onlyLength =
    ( "Aw"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Nothing
            , octave = 3
            , length = "w"
            , parseStart = 0
            , parseEnd = 2
            }
      ]
    )


lengthAndOctave =
    ( "Aq1"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Nothing
            , octave = 1
            , length = "q"
            , parseStart = 0
            , parseEnd = 3
            }
      ]
    )


withIgnorables =
    ( "uAq uuuuh 1"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Nothing
            , octave = 3
            , length = "q"
            , parseStart = 1
            , parseEnd = 3
            }
      ]
    )


withHashtag =
    ( "#ngale A+t #ngale"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Just Sharp
            , octave = 3
            , length = "t"
            , parseStart = 7
            , parseEnd = 10
            }
      ]
    )


withMention =
    ( "A+t @NightingaleSpc"
    , [ Note
            { tweetId = 0
            , letter = "A"
            , accidental = Just Sharp
            , octave = 3
            , length = "t"
            , parseStart = 0
            , parseEnd = 3
            }
      ]
    )


makeTest : String -> ( String, List Note ) -> Test
makeTest name ( src, res ) =
    test name <| assertEqual res (notes 0 src)


tests : Test
tests =
    suite "A single note"
        [ makeTest "All parts" allParts
        , makeTest "With a space" space
        , makeTest "With only an accidental" onlyAccidental
        , makeTest "With only length" onlyLength
        , makeTest "With length and octave" lengthAndOctave
        , makeTest "With other characters" withIgnorables
        , makeTest "With hashtag" withHashtag
        , makeTest "With mention" withMention
        ]

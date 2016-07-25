module Note.Tests exposing (..)

import ElmTest exposing (..)
import Note.Parser.Tests.SingleNote


tests : Test
tests =
    suite "Parser"
        [ Note.Parser.Tests.SingleNote.tests
        ]

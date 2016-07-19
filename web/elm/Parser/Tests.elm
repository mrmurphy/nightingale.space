module Parser.Tests exposing (..)

import ElmTest exposing (..)
import Parser.Tests.SingleNote


tests : Test
tests =
    suite "Parser"
        [ Parser.Tests.SingleNote.tests
        ]

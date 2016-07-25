module TestRunner exposing (..)

import ElmTest exposing (..)
import Note.Tests


tests : Test
tests =
    suite "All"
        [ Note.Tests.tests
        ]


main : Program Never
main =
    runSuite tests

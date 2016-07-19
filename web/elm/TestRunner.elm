module TestRunner exposing (..)

import ElmTest exposing (..)
import Parser.Tests


tests : Test
tests =
    suite "All"
        [ Parser.Tests.tests
        ]


main : Program Never
main =
    runSuite tests

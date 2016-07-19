module TestRunner exposing (..)

import ElmTest exposing (..)
import Parser exposing (..)


tests : Test
tests =
    suite "Parser"
        [ test "Has a foo" (assertEqual "bar" foo)
        ]


main : Program Never
main =
    runSuite tests

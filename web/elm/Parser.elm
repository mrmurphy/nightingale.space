module Parser exposing (..)

import Combine exposing (parse)
import Combine.Infix exposing ((*>), (<*>))
import Parser.Types exposing (Note(Note))
import Parser.Note
import Regex exposing (regex)
import Maybe.Extra
import String
import Parser.Types exposing (Accidental(Sharp, Flat))


notes : String -> List Note
notes str =
    let
        body context =
            case context.input of
                "" ->
                    []

                more ->
                    let
                        ( maybeNote, newContext ) =
                            Parser.Note.parse { input = context.input, position = context.position }
                    in
                        case maybeNote of
                            Nothing ->
                                body newContext

                            Just note ->
                                note :: (body newContext)
    in
        body { input = str, position = 0 }

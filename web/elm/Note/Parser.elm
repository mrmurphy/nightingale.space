module Note.Parser exposing (notes)

import Combine
import Combine.Infix exposing ((<|>))
import Note exposing (Note(Note), Accidental(Sharp, Flat))
import Regex exposing (regex)
import Maybe.Extra
import String


noteRegex =
    "([a-gA-G_]).*?([+-])?.*?([tseqhwTSEQHW])?.*?([0-8])?"


notNoteRegex =
    "[^a-gA-G_]*"


hashtagRegex =
    "#ngale"


parse : Combine.Context -> ( Maybe Note, Combine.Context )
parse context =
    let
        noteStrParser : Combine.Parser String
        noteStrParser =
            (Combine.map (always "") (Combine.regex hashtagRegex))
                <|> (Combine.regex noteRegex)
                <|> (Combine.regex notNoteRegex)

        ( noteResult, newContext ) =
            Combine.parse noteStrParser context.input
    in
        case noteResult of
            Err _ ->
                ( Nothing, newContext )

            Ok noteStr ->
                ( fromString noteStr context.position (context.position + newContext.position), { input = newContext.input, position = newContext.position + context.position } )


maybeStringToInt : Maybe String -> Int -> Int
maybeStringToInt maybeString default =
    let
        intified =
            maybeString
                `Maybe.andThen` (\s -> Result.toMaybe (String.toInt s))
    in
        Maybe.withDefault default intified


stringToAccidental : String -> Maybe Accidental
stringToAccidental string =
    case string of
        "+" ->
            Just Sharp

        "-" ->
            Just Flat

        _ ->
            Nothing


fromString : String -> Int -> Int -> Maybe Note
fromString str start end =
    let
        matches =
            Regex.find (Regex.AtMost 1) (Regex.regex noteRegex) str
    in
        case matches of
            x :: _ ->
                case x.submatches of
                    [ letter, accidental, length, octave ] ->
                        let
                            note : Note
                            note =
                                Note
                                    { letter = Maybe.withDefault "?bad note" letter
                                    , accidental = accidental `Maybe.andThen` stringToAccidental
                                    , octave = maybeStringToInt octave 3
                                    , length = Maybe.withDefault "s" length
                                    , parseStart = start
                                    , parseEnd = end
                                    }
                        in
                            Just note

                    _ ->
                        Nothing

            [] ->
                Nothing


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
                            parse { input = context.input, position = context.position }
                    in
                        case maybeNote of
                            Nothing ->
                                body newContext

                            Just note ->
                                note :: (body newContext)
    in
        body { input = str, position = 0 }

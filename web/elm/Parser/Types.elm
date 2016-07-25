module Parser.Types exposing (..)


type Accidental
    = Sharp
    | Flat



-- TODO: Move Note and Accidental into the Notes.elm file


type Note
    = Note
        { letter : String
        , accidental : Maybe Accidental
        , octave : Int
        , length : String
        , parseStart : Int
        , parseEnd : Int
        }

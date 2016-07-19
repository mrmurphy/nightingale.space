module Parser.Types exposing (..)


type Accidental
    = Sharp
    | Flat


type Note
    = Note
        { letter : String
        , accidental : Maybe Accidental
        , octave : Int
        , length : Int
        , parseStart : Int
        , parseEnd : Int
        }

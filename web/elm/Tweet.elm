module Tweet exposing (..)

import Parser.Types exposing (Note)
import Parser exposing (notes)
import Json.Decode as JD exposing ((:=))


type alias Tweet =
    { id : Int
    , author : String
    , text : String
    , pic : String
    , notes : List Note
    }


tweetDecoder : Int -> JD.Decoder Tweet
tweetDecoder id =
    JD.object5 Tweet
        (JD.succeed id)
        ("author" := JD.string)
        ("text" := JD.string)
        ("pic" := JD.string)
        (JD.map notes ("text" := JD.string))

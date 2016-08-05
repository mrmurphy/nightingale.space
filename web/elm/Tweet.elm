module Tweet exposing (..)

import Note exposing (Note)
import Note.Parser exposing (notes)
import Json.Decode as JD exposing ((:=))
import Html exposing (..)
import Html.Attributes exposing (..)


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
        (JD.map (notes id) ("text" := JD.string))


view : Tweet -> Html msg
view tweet =
    div [ class "tweetWrapper" ]
        [ div [ class "tweetHeader" ]
            [ img [ src tweet.pic, class "avatar" ] []
            , text tweet.author
            ]
        , div [ class "tweetBody" ]
            [ text tweet.text ]
        ]

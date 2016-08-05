module Tweet exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as JD exposing ((:=))
import Note exposing (Note)
import Note.Parser exposing (notes)
import String


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


view : Tweet -> Maybe Note.PortNote -> Html msg
view tweet playingNote =
    div [ class "tweetWrapper" ]
        [ div [ class "tweetHeader" ]
            [ img [ src tweet.pic, class "avatar" ] []
            , text tweet.author
            ]
        , div [ class "tweetBody" ]
            <| case playingNote of
                Nothing ->
                    [ text tweet.text ]

                Just note ->
                    let
                        beforeHilight =
                            String.slice 0 note.parseStart tweet.text

                        hilight =
                            String.slice note.parseStart note.parseEnd tweet.text

                        afterHilight =
                            String.slice note.parseEnd (String.length tweet.text) tweet.text
                    in
                        [ text beforeHilight
                        , p [ class "playing" ] [ text hilight ]
                        , text afterHilight
                        ]
        ]

port module Player exposing (tweetsView, controlsView, subscriptions, init, initCmds, update, Model, Msg(GotTweet))

import Note exposing (PortNote)
import Tweet exposing (Tweet)
import Html exposing (..)
import Html.Attributes exposing (..)


-- PORTS


port play : List PortNote -> Cmd msg


port playing : (Maybe PortNote -> msg) -> Sub msg



-- CMDS


type Msg
    = ShowPlaying (Maybe PortNote)
    | GotTweet Tweet



-- MODEL


type alias Model =
    { playing : Maybe PortNote
    , queue : List Tweet
    }


init : Model
init =
    { playing = Nothing
    , queue = []
    }


initCmds =
    Cmd.none



-- SUBS


subscriptions =
    playing ShowPlaying



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowPlaying playing ->
            { model | playing = playing } ! []

        GotTweet tweet ->
            { model | queue = List.reverse (tweet :: (List.reverse model.queue)) }
                ! [ play (List.map Note.toPortNote tweet.notes) ]



-- VIEW


tweetsView : Model -> Html Msg
tweetsView model =
    div [ class "tweetsContainer" ]
        [ case List.head model.queue of
            Nothing ->
                text "Waiting for more tweets..."

            Just tweet ->
                Tweet.view tweet
        ]


controlsView : Model -> Html Msg
controlsView model =
    div [ class "controlsContainer" ]
        [ div [ class "controlWrapper" ]
            [ button []
                [ i [ class "fa fa-pause-circle-o" ] []
                ]
            , div [ class "group1" ]
                [ div [ class "inputGroup" ]
                    [ label [] [ text "Topic: " ]
                    , input [ value <| "#ngale" ] []
                    ]
                , div [ class "queueInfoGroup" ]
                    [ text "Tweets in queue: "
                    , text <| toString <| List.length model.queue
                    ]
                ]
            ]
        ]

port module Player exposing (tweetsView, controlsView, subscriptions, init, initCmds, update, Model, Msg(GotTweet))

import Note exposing (PortNote)
import Tweet exposing (Tweet)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


-- PORTS


port play : List PortNote -> Cmd msg


port pause : () -> Cmd msg


port resume : () -> Cmd msg


port playing : (Maybe PortNote -> msg) -> Sub msg



-- CMDS


type Msg
    = ShowPlaying (Maybe PortNote)
    | GotTweet Tweet
    | SetPause Bool



-- MODEL


type alias Model =
    { playing : Maybe PortNote
    , queue : List Tweet
    , isPaused : Bool
    }


init : Model
init =
    { playing = Nothing
    , queue = []
    , isPaused = False
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
            let
                queue =
                    case playing of
                        Just note ->
                            case model.queue of
                                x :: xs ->
                                    if x.id /= note.tweetId then
                                        xs
                                    else
                                        model.queue

                                _ ->
                                    model.queue

                        Nothing ->
                            model.queue
            in
                { model | playing = playing, queue = queue } ! []

        GotTweet tweet ->
            { model | queue = List.reverse (tweet :: (List.reverse model.queue)) }
                ! [ play (List.map Note.toPortNote tweet.notes) ]

        SetPause isPaused ->
            { model | isPaused = isPaused }
                ! [ case isPaused of
                        True ->
                            pause ()

                        False ->
                            resume ()
                  ]



-- VIEW


tweetsView : Model -> Html Msg
tweetsView model =
    div [ class "tweetsContainer" ]
        [ case List.head model.queue of
            Nothing ->
                text "Waiting for more tweets..."

            Just tweet ->
                Tweet.view tweet model.playing
        ]


controlsView : Model -> Html Msg
controlsView model =
    div [ class "controlsContainer" ]
        [ div [ class "controlWrapper" ]
            [ button [ onClick (SetPause (not model.isPaused)) ]
                (let
                    className =
                        case model.isPaused of
                            True ->
                                "fa fa-play-circle-o"

                            False ->
                                "fa fa-pause-circle-o"
                 in
                    [ i [ class className ] [] ]
                )
            , div [ class "group1" ]
                [ div [ class "topics" ]
                    [ text "Listening for tweets to:"
                    , ul []
                        [ li [] [ text "@nightingalespc" ]
                        , li [] [ text "#elmconf" ]
                        ]
                    ]
                , div [ class "queueInfoGroup" ]
                    [ text "Tweets in queue: "
                    , text
                        <| toString
                        <| let
                            count =
                                (List.length model.queue) - 1
                           in
                            if count == -1 then
                                0
                            else
                                count
                    ]
                ]
            ]
        ]

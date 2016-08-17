port module Main exposing (..)

import Cmd.Extra exposing (message)
import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Note exposing (Note)
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket
import Platform.Cmd
import Player
import Tweet exposing (Tweet, tweetDecoder)


-- MAIN


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"



-- MODEL


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveTweet JE.Value
    | JoinChannel
    | LeaveChannel
    | NoOp
    | PlayerMsg Player.Msg


type alias Model =
    { player : Player.Model
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "tweet" "tweets:lobby" ReceiveTweet


initModel : Model
initModel =
    Model Player.init initPhxSocket


init : ( Model, Cmd Msg )
init =
    initModel ! [ message JoinChannel, Player.initCmds ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.phxSocket PhoenixMsg
        , Sub.map PlayerMsg Player.subscriptions
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveTweet raw ->
            case JD.decodeValue (tweetDecoder (List.length model.player.queue)) raw of
                Ok tweet ->
                    let
                        ( playerMdl, playerCmds ) =
                            Player.update (Player.GotTweet tweet) model.player
                    in
                        ( { model | player = playerMdl }
                        , Cmd.map PlayerMsg playerCmds
                        )

                Err error ->
                    let
                        _ =
                            Debug.crash error
                    in
                        ( model, Cmd.none )

        PlayerMsg msg ->
            let
                ( playerMdl, playerCmds ) =
                    Player.update msg model.player
            in
                ( { model | player = playerMdl }, Cmd.map PlayerMsg playerCmds )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "tweets:lobby"

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        LeaveChannel ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.leave "tweets:lobby" model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "rootContainer" ]
        [ div [ class "headerContainer" ]
            [ img [ class "logo", src "/images/logo.svg" ] []
            ]
        , Html.App.map PlayerMsg <| Player.tweetsView model.player
        , Html.App.map PlayerMsg <| Player.controlsView model.player
        , div [ class "footerContainer" ]
            [ text "nightingale.space by "
            , a [ href "https://twitter.com/splodingsocks" ]
                [ text " @splodingsocks" ]
            ]
        ]

module Main exposing (..)

import Cmd.Extra exposing (message)
import Html exposing (Html, h3, div, text, ul, li, input, form, button, br, table, tbody, tr, td)
import Html.App
import Html.Attributes exposing (type', value)
import Html.Events exposing (onInput, onSubmit, onClick)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Parser.Types exposing (Note)
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket
import Platform.Cmd
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


type alias Model =
    { queue : List Tweet
    , playing : Maybe Note
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "tweet" "tweets:lobby" ReceiveTweet


initModel : Model
initModel =
    Model [] Nothing initPhxSocket


init : ( Model, Cmd Msg )
init =
    initModel ! [ message JoinChannel ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveTweet raw ->
            case JD.decodeValue (tweetDecoder (List.length model.queue)) raw of
                Ok tweet ->
                    let
                        _ =
                            Debug.log "got a tweet" tweet
                    in
                        ( { model | queue = tweet :: model.queue }
                        , Cmd.none
                        )

                Err error ->
                    let
                        _ =
                            Debug.crash error
                    in
                        ( model, Cmd.none )

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
    div []
        [ h3 [] [ text "Messages:" ]
        , ul [] ((List.reverse << List.map renderTweet) model.queue)
        ]


renderTweet : Tweet -> Html Msg
renderTweet tweet =
    li [] [ text <| toString tweet ]

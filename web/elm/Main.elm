module Main exposing (..)

import Html exposing (Html, h3, div, text, ul, li, input, form, button, br, table, tbody, tr, td)
import Html.Attributes exposing (type', value)
import Html.Events exposing (onInput, onSubmit, onClick)
import Html.App
import Platform.Cmd
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import Cmd.Extra exposing (message)


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
    | ShowJoinedMessage String
    | ShowLeftMessage String
    | NoOp


type alias Model =
    { messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "tweet" "tweets:lobby" ReceiveTweet


initModel : Model
initModel =
    Model [] initPhxSocket


init : ( Model, Cmd Msg )
init =
    initModel ! [ message JoinChannel ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


type alias Tweet =
    { author : String
    , text : String
    , pic : String
    }


tweetDecoder : JD.Decoder Tweet
tweetDecoder =
    JD.object3 Tweet
        ("author" := JD.string)
        ("text" := JD.string)
        ("pic" := JD.string)



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
            case JD.decodeValue tweetDecoder raw of
                Ok tweetBody ->
                    let
                        _ =
                            Debug.log "got a tweet" tweetBody
                    in
                        ( { model | messages = (toString tweetBody) :: model.messages }
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
                        |> Phoenix.Channel.onJoin (always (ShowJoinedMessage "tweets:lobby"))
                        |> Phoenix.Channel.onClose (always (ShowLeftMessage "tweets:lobby"))

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

        ShowJoinedMessage channelName ->
            ( { model | messages = ("Joined channel " ++ channelName) :: model.messages }
            , Cmd.none
            )

        ShowLeftMessage channelName ->
            ( { model | messages = ("Left channel " ++ channelName) :: model.messages }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Messages:" ]
        , ul [] ((List.reverse << List.map renderMessage) model.messages)
        ]


renderMessage : String -> Html Msg
renderMessage str =
    li [] [ text str ]

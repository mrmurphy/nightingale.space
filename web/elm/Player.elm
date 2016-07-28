port module Player exposing (view, subscriptions, init, initCmds, update, Model, Msg(GotTweet))

import Note exposing (PortNote)
import Tweet exposing (Tweet)
import Html exposing (div, h1, text, Html, p)


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


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text <| toString model.queue ]
        , p [] [ text <| toString model.playing ]
        ]

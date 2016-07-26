port module Player exposing (view, subscriptions, init, initCmds, update, Model, Msg(GotTweet))

import Note exposing (PortNote)
import Tweet exposing (Tweet)
import Html exposing (div, h1, text, Html, p)


type alias Playing =
    { tweetId : Int
    , highlightStart : Int
    , highlightEnd : Int
    }



-- PORTS


port play : ( Int, PortNote ) -> Cmd msg


port playing : (Playing -> msg) -> Sub msg



-- CMDS


type Msg
    = ShowPlaying Playing
    | GotTweet Tweet



-- MODEL


type alias Model =
    { playing : Maybe Playing
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
            { model | playing = Just playing } ! []

        GotTweet tweet ->
            { model | queue = List.reverse (tweet :: (List.reverse model.queue)) } ! []



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text <| toString model.queue ]
        , p [] [ text <| toString model.playing ]
        ]

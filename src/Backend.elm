module Backend exposing (..)

import Lamdera
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \_ -> Lamdera.onConnect ClientConnected
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { players = [], nextPlayerId = 0 }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId _ ->
            ( { model
                | players =
                    { id = model.nextPlayerId
                    , sessionId = sessionId
                    , x = 0
                    , y = 0
                    , z = 0
                    }
                        :: model.players
                , nextPlayerId = model.nextPlayerId + 1
              }
            , Cmd.none
            )

        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : Lamdera.SessionId -> Lamdera.ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        FromFrontendTick _ ->
            ( model, Cmd.none )

        NoOpToBackend ->
            ( model, Cmd.none )

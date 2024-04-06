module Backend exposing (..)

import Constants
import Direction3d
import Duration
import Frame3d
import Lamdera
import Length
import Mass
import Physics.Body
import Physics.Material
import Physics.World
import Plane3d
import Platform.Sub as Sub
import Point3d
import Quantity
import Set
import Speed
import Sphere3d
import Time
import Types exposing (..)
import Vector3d


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions =
            \model ->
                Sub.batch
                    [ Lamdera.onConnect (\s c -> ClientConnected s c)
                    , Lamdera.onDisconnect (\s c -> ClientDisconnected s c)
                    , if
                        model.world
                            |> Physics.World.bodies
                            |> List.all (\body -> Physics.Body.data body == BackendStatic)
                      then
                        Sub.none

                      else
                        Time.every (1000 / 60) BackendTick
                    ]
        }


baseWorld =
    Physics.World.empty
        |> Physics.World.withGravity
            Constants.gravity
            Direction3d.negativeZ
        |> Physics.World.add
            (Physics.Body.plane BackendStatic
                |> Physics.Body.moveTo (Point3d.meters 0 0 0)
                |> Physics.Body.withMaterial (Physics.Material.custom { friction = Constants.friction, bounciness = Constants.bounciness })
            )


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { world = baseWorld
      , previousTick = Nothing
      , nextId = 0
      }
    , Cmd.none
    )


mapPlayerData func body =
    case Physics.Body.data body of
        BackendPlayer player ->
            body |> Physics.Body.withData (BackendPlayer (func player))

        _ ->
            body


simulate :
    Duration.Duration
    -> Physics.World.World BackendWorldData
    -> Physics.World.World BackendWorldData
simulate duration world =
    world
        |> Physics.World.update
            (\body ->
                case Physics.Body.data body of
                    BackendPlayer player ->
                        body
                            |> Physics.Body.applyTorque player.torque
                            |> Physics.Body.withData
                                (BackendPlayer
                                    { player
                                        | localTime = duration |> Duration.addTo player.localTime
                                    }
                                )

                    _ ->
                        body
            )
        |> Physics.World.simulate duration
        |> Physics.World.update
            (\body ->
                case Physics.Body.data body of
                    BackendPlayer _ ->
                        let
                            { x, y } =
                                Physics.Body.frame body
                                    |> Frame3d.originPoint
                                    |> Point3d.toRecord Length.inInches
                        in
                        if
                            Physics.Body.frame body
                                |> Frame3d.originPoint
                                |> Point3d.signedDistanceFrom Plane3d.xy
                                |> Quantity.lessThan (Length.inches 0.49)
                        then
                            body
                                |> Physics.Body.withFrame (Physics.Body.frame body |> Frame3d.moveTo (Point3d.inches x y 0.5))
                                |> Physics.Body.withBehavior
                                    (Physics.Body.dynamic (Mass.kilograms 1)
                                        (body |> Physics.Body.velocity |> Vector3d.projectOnto Plane3d.xy)
                                        (body |> Physics.Body.angularVelocity)
                                    )

                        else
                            body
                                |> Physics.Body.withBehavior
                                    (Physics.Body.dynamic (Mass.kilograms 1)
                                        (body |> Physics.Body.velocity |> Vector3d.projectOnto Plane3d.xy)
                                        (body |> Physics.Body.angularVelocity)
                                    )

                    _ ->
                        body
            )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            ( { model
                | world =
                    model.world
                        |> Physics.World.update
                            (mapPlayerData
                                (\data ->
                                    if data.sessionId == sessionId then
                                        { data | clients = data.clients |> Set.insert clientId }

                                    else
                                        data
                                )
                            )
              }
            , Cmd.none
            )

        ClientDisconnected sessionId clientId ->
            let
                newWorld =
                    model.world
                        |> Physics.World.update
                            (mapPlayerData
                                (\data ->
                                    if data.sessionId == sessionId then
                                        { data | clients = data.clients |> Set.remove clientId }

                                    else
                                        data
                                )
                            )
                        |> Physics.World.keepIf
                            (\body ->
                                case Physics.Body.data body of
                                    BackendPlayer player ->
                                        not (Set.isEmpty player.clients)

                                    _ ->
                                        True
                            )
            in
            ( { model
                | world =
                    if
                        model.world
                            |> Physics.World.bodies
                            |> List.all (\body -> Physics.Body.data body == BackendStatic)
                    then
                        baseWorld

                    else
                        newWorld
              }
            , Cmd.none
            )

        BackendTick time ->
            case model.previousTick of
                Just { previousTickTime, previousUpdateTime } ->
                    let
                        tickDuration =
                            Duration.from previousTickTime time

                        newWorld =
                            model.world |> simulate tickDuration

                        willUpdate =
                            (Duration.from previousUpdateTime time |> Duration.inMilliseconds) > 30
                    in
                    ( { model
                        | world = newWorld
                        , previousTick =
                            Just
                                { previousTickTime = time
                                , previousUpdateTime =
                                    if willUpdate then
                                        time

                                    else
                                        previousUpdateTime
                                }
                      }
                    , if willUpdate then
                        Lamdera.broadcast (UpdateEntities (getWirableWorldState newWorld))

                      else
                        Cmd.none
                    )

                Nothing ->
                    ( { model | previousTick = Just { previousTickTime = time, previousUpdateTime = time } }, Cmd.none )

        NoOpBackendMsg ->
            ( model, Cmd.none )


getWirableWorldState world =
    Physics.World.bodies world
        |> List.filterMap
            (\body ->
                case Physics.Body.data body of
                    BackendPlayer player ->
                        Just
                            { id = player.id
                            , frame = Physics.Body.frame body
                            , velocity = Physics.Body.velocity body
                            , angularVelocity = Physics.Body.angularVelocity body
                            , movement = player.torque
                            , time = player.localTime
                            }

                    _ ->
                        Nothing
            )


updateFromFrontend : Lamdera.SessionId -> Lamdera.ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        Join _ ->
            if
                model.world
                    |> Physics.World.bodies
                    |> List.any
                        (\body ->
                            case body |> Physics.Body.data of
                                BackendPlayer player ->
                                    player.sessionId == sessionId

                                _ ->
                                    False
                        )
            then
                ( model, Cmd.none )

            else
                let
                    newWorld =
                        model.world
                            |> Physics.World.add
                                (Physics.Body.sphere
                                    (Sphere3d.atOrigin (Length.inches 1))
                                    (BackendPlayer
                                        { sessionId = sessionId
                                        , clients = Set.singleton clientId
                                        , id = model.nextId
                                        , torque = Vector3d.zero
                                        , localTime = Time.millisToPosix 0
                                        }
                                    )
                                    |> Physics.Body.withFrame (Frame3d.atPoint (Point3d.inches 0 (model.nextId * 3 |> toFloat) 0.5))
                                    |> Physics.Body.withBehavior
                                        (Physics.Body.dynamic (Mass.kilograms 1)
                                            (Vector3d.fromTuple Speed.feetPerSecond ( 0.1, 0.1, 2 ))
                                            Vector3d.zero
                                        )
                                    |> Physics.Body.withMaterial (Physics.Material.custom { friction = Constants.friction, bounciness = Constants.bounciness })
                                    |> Physics.Body.withDamping { linear = Constants.dampingLinear, angular = Constants.dampingAngular }
                                )
                in
                ( { model
                    | world = newWorld
                    , nextId = model.nextId + 1
                  }
                , Lamdera.sendToFrontend sessionId (AssignId model.nextId)
                )

        UpdateMovement movement time ->
            let
                newModel =
                    { model
                        | world =
                            model.world
                                |> Physics.World.update
                                    (mapPlayerData
                                        (\player ->
                                            if player.sessionId == sessionId then
                                                { player
                                                    | torque = movement
                                                    , localTime = time
                                                }

                                            else
                                                player
                                        )
                                    )
                    }
            in
            ( newModel, Cmd.none )

        NoOpToBackend ->
            ( model, Cmd.none )

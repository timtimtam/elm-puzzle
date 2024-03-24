port module Frontend exposing (app)

import Acceleration
import Angle
import Axis2d
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camera3d
import Circle2d
import Color
import Direction2d
import Direction3d
import Duration
import Force
import Frame3d
import Geometry.Svg
import Html
import Html.Attributes
import Html.Events
import Html.Events.Extra.Touch
import Html.Lazy
import Illuminance
import Json.Decode
import Json.Encode
import Keyboard.Event
import Keyboard.Key
import Lamdera
import Lamdera.Json as Json
import Length
import List.Extra
import Luminance
import LuminousFlux
import Mass
import Physics.Body
import Physics.Coordinates
import Physics.Material
import Physics.World
import Pixels
import Platform.Cmd as Cmd
import Point2d
import Point3d
import Quantity
import Scene3d
import Scene3d.Light
import Scene3d.Material
import SketchPlane3d
import Sphere3d
import Svg
import Svg.Attributes
import Task
import Torque
import Types exposing (..)
import Url
import Vector2d
import Vector3d
import Viewpoint3d


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = \_ -> NoOpFrontendMsg
        , onUrlChange = \_ -> NoOpFrontendMsg
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


handleResult v =
    case v of
        Err _ ->
            NoOpFrontendMsg

        Ok vp ->
            WindowResized
                (vp.scene.width |> Basics.round |> Pixels.int)
                (vp.scene.height |> Basics.round |> Pixels.int)


init : Url.Url -> Browser.Navigation.Key -> ( Model, Cmd FrontendMsg )
init _ _ =
    ( { width = Quantity.zero
      , height = Quantity.zero
      , cameraAngle = Maybe.withDefault Direction3d.positiveX (Direction3d.from (Point3d.inches 0 0 0) (Point3d.inches 5 -4 2))
      , mouseButtonState = Up
      , leftKey = Up
      , rightKey = Up
      , upKey = Up
      , downKey = Up
      , joystickOffset = Vector2d.zero
      , viewPivotDelta = Vector2d.zero
      , lightPosition = ( 3, 3, 3 ) |> Point3d.fromTuple Length.inches
      , touches = NotOneFinger
      , lastContact = Mouse
      , pointerCapture = PointerNotLocked
      , world = baseWorld
      , playerColorTexture = Nothing
      , playerRoughnessTexture = Nothing
      }
    , Cmd.batch
        [ Task.attempt handleResult Browser.Dom.getViewport
        , Scene3d.Material.loadWith Scene3d.Material.nearestNeighborFiltering "/ball-color.png"
            |> Task.attempt GotColorTexture
        , Scene3d.Material.loadWith Scene3d.Material.nearestNeighborFiltering "/ball-roughness.png"
            |> Task.attempt GotRoughnessTexture
        ]
    )


type PlayerCoordinates
    = PlayerCoordinates


radiansPerPixel =
    Angle.radians -0.004 |> Quantity.per (Pixels.float 1)


cameraFrame3d :
    Point3d.Point3d Length.Meters Physics.Coordinates.WorldCoordinates
    -> Direction3d.Direction3d Physics.Coordinates.WorldCoordinates
    -> Maybe (Frame3d.Frame3d Length.Meters Physics.Coordinates.WorldCoordinates { defines : PlayerCoordinates })
cameraFrame3d position angle =
    let
        globalUp =
            Direction3d.toVector Direction3d.positiveZ

        globalforward =
            Direction3d.toVector angle

        globalLeft =
            Vector3d.cross globalUp globalforward
    in
    Direction3d.orthonormalize globalforward globalUp globalLeft
        |> Maybe.map
            (\( playerForward, playerUp, playerLeft ) ->
                Frame3d.unsafe
                    { originPoint = position
                    , xDirection = playerLeft
                    , yDirection = playerForward
                    , zDirection = playerUp
                    }
            )


update : FrontendMsg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        WindowResized w h ->
            ( { model | width = w, height = h }, Cmd.none )

        Tick tickMilliseconds ->
            let
                angleDeltaVector =
                    model.viewPivotDelta
                        |> Vector2d.at radiansPerPixel
                        |> Vector2d.mirrorAcross Axis2d.x

                world =
                    simulate
                        { joystick = model.joystickOffset
                        , facingAngle =
                            model.cameraAngle
                                |> Direction3d.azimuthIn SketchPlane3d.xy
                        }
                        (Duration.milliseconds tickMilliseconds)
                        model.world
            in
            cameraFrame3d Point3d.origin model.cameraAngle
                |> Maybe.map
                    (\frame ->
                        let
                            newAngle =
                                frame
                                    |> Frame3d.rotateAroundOwn Frame3d.zAxis (angleDeltaVector |> Vector2d.xComponent)
                                    |> Frame3d.rotateAroundOwn Frame3d.xAxis (angleDeltaVector |> Vector2d.yComponent)
                                    |> Frame3d.yDirection
                        in
                        ( { model
                            | world = world
                            , viewPivotDelta = Vector2d.zero
                            , cameraAngle = newAngle
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        MouseMoved offset ->
            ( { model
                | viewPivotDelta =
                    case model.pointerCapture of
                        PointerLocked ->
                            model.viewPivotDelta |> Vector2d.plus offset

                        PointerNotLocked ->
                            model.viewPivotDelta
                , lastContact = Mouse
              }
            , Cmd.none
            )

        MouseDown ->
            ( { model | mouseButtonState = Down, lastContact = Mouse }, requestPointerLock Json.Encode.null )

        MouseUp ->
            ( { model | mouseButtonState = Up, lastContact = Mouse }, Cmd.none )

        ArrowKeyChanged key state ->
            let
                newModel =
                    case key of
                        UpKey ->
                            { model | upKey = state }

                        DownKey ->
                            { model | downKey = state }

                        LeftKey ->
                            { model | leftKey = state }

                        RightKey ->
                            { model | rightKey = state }

                newJoystickX =
                    case ( newModel.leftKey, newModel.rightKey ) of
                        ( Up, Down ) ->
                            1

                        ( Down, Up ) ->
                            -1

                        _ ->
                            0

                newJoystickY =
                    case ( newModel.upKey, newModel.downKey ) of
                        ( Up, Down ) ->
                            1

                        ( Down, Up ) ->
                            -1

                        _ ->
                            0

                newXY =
                    Vector2d.fromUnitless { x = newJoystickX, y = newJoystickY } |> capVector2d
            in
            ( { newModel | joystickOffset = newXY }, Cmd.none )

        TouchesChanged contact ->
            let
                delta =
                    case ( model.touches, contact ) of
                        ( OneFinger old, OneFinger new ) ->
                            if old.identifier == new.identifier then
                                Vector2d.from old.screenPos new.screenPos

                            else
                                Vector2d.zero

                        _ ->
                            Vector2d.zero

                totalDelta =
                    model.viewPivotDelta |> Vector2d.plus delta
            in
            ( { model | touches = contact, viewPivotDelta = totalDelta, lastContact = Touch }, Cmd.none )

        JoystickTouchChanged contact ->
            let
                newJoystickPosition =
                    case contact of
                        OneFinger { screenPos } ->
                            Vector2d.from (getJoystickOrigin model.height) screenPos
                                |> Vector2d.at_ pixelsPerJoystickWidth

                        NotOneFinger ->
                            Vector2d.zero
            in
            ( { model | lastContact = Touch, joystickOffset = newJoystickPosition }, Cmd.none )

        ShootClicked ->
            ( model, Cmd.none )

        GotPointerLock ->
            ( { model | pointerCapture = PointerLocked }, Cmd.none )

        LostPointerLock ->
            ( { model | pointerCapture = PointerNotLocked }, Cmd.none )

        GotColorTexture (Ok playerColorTexture) ->
            ( { model | playerColorTexture = Just playerColorTexture }
            , Cmd.none
            )

        GotColorTexture (Err _) ->
            ( model, Cmd.none )

        GotRoughnessTexture (Ok playerRoughnessTexture) ->
            ( { model | playerRoughnessTexture = Just playerRoughnessTexture }
            , Cmd.none
            )

        GotRoughnessTexture (Err _) ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


friction =
    0.002


bounciness =
    0.5


dampingLinear =
    0.3


dampingAngular =
    0.2


maxTorque =
    Torque.newtonMeters 0.05


baseWorld =
    Physics.World.empty
        |> Physics.World.withGravity
            (Acceleration.metersPerSecondSquared 9.80665)
            Direction3d.negativeZ
        |> Physics.World.add
            (Physics.Body.sphere
                (Sphere3d.atOrigin (Length.inches 1))
                Player
                |> Physics.Body.moveTo (Point3d.inches 0 0 0.5)
                |> Physics.Body.withBehavior (Physics.Body.dynamic (Mass.kilograms 1))
                |> Physics.Body.withMaterial (Physics.Material.custom { friction = friction, bounciness = bounciness })
                |> Physics.Body.withDamping { linear = dampingLinear, angular = dampingAngular }
            )
        |> Physics.World.add
            (Physics.Body.sphere
                (Sphere3d.atOrigin (Length.inches 1))
                Dynamic
                |> Physics.Body.moveTo (Point3d.inches 10 0 0.5)
                |> Physics.Body.withBehavior (Physics.Body.dynamic (Mass.kilograms 1))
                |> Physics.Body.withMaterial (Physics.Material.custom { friction = friction, bounciness = bounciness })
                |> Physics.Body.withDamping { linear = dampingLinear, angular = dampingAngular }
            )
        |> Physics.World.add
            (Physics.Body.plane Static
                |> Physics.Body.moveTo (Point3d.meters 0 0 0)
                |> Physics.Body.withMaterial (Physics.Material.custom { friction = friction, bounciness = bounciness })
            )


updateFromBackend msg model =
    case msg of
        FromBackendTick _ ->
            ( model, Cmd.none )

        NoOpToFrontend ->
            ( model, Cmd.none )


applyTorque : Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates -> Physics.Body.Body data -> Physics.Body.Body data
applyTorque torque body =
    case Vector3d.direction torque of
        Just torqueDirection ->
            let
                centerOfMass =
                    Physics.Body.centerOfMass body |> Point3d.placeIn (Physics.Body.frame body)

                offsetLength =
                    Length.inches 0.1

                frame =
                    Frame3d.withZDirection torqueDirection centerOfMass

                offsetVector =
                    Frame3d.yDirection frame |> Vector3d.withLength offsetLength

                newtons =
                    Vector3d.length torque
                        |> Quantity.over_ offsetLength
                        |> Quantity.half
            in
            body
                |> Physics.Body.applyForce
                    newtons
                    (Frame3d.xDirection frame)
                    (centerOfMass |> Point3d.translateBy offsetVector)
                |> Physics.Body.applyForce
                    newtons
                    (Frame3d.xDirection frame |> Direction3d.reverse)
                    (centerOfMass |> Point3d.translateBy (Vector3d.reverse offsetVector))

        Nothing ->
            body


simulate :
    { joystick : Vector2d.Vector2d Quantity.Unitless ScreenCoordinates
    , facingAngle : Angle.Angle
    }
    -> Duration.Duration
    -> Physics.World.World WorldData
    -> Physics.World.World WorldData
simulate { joystick, facingAngle } duration world =
    let
        joystickCapped =
            (if Vector2d.length joystick |> Quantity.greaterThan (Quantity.float 1) then
                Vector2d.normalize joystick

             else
                joystick
            )
                |> Vector2d.mirrorAcross Axis2d.x
                |> Vector2d.rotateBy facingAngle
                |> Vector2d.rotateBy (Angle.turns 0.25)

        torque =
            maxTorque |> Quantity.timesUnitless (Vector2d.length joystickCapped)
    in
    world
        |> Physics.World.update
            (\body ->
                case Physics.Body.data body of
                    Player ->
                        let
                            direction =
                                case Vector2d.direction joystickCapped of
                                    Just direction2d ->
                                        Direction3d.on SketchPlane3d.xy
                                            (direction2d |> Direction2d.rotateBy (Angle.turns -0.25))

                                    Nothing ->
                                        Direction3d.z
                        in
                        body
                            |> applyTorque (direction |> Vector3d.withLength torque)

                    _ ->
                        body
            )
        |> Physics.World.simulate duration


tupleSubtract a b =
    case ( a, b ) of
        ( ( a1, a2 ), ( b1, b2 ) ) ->
            ( a1 - b1, a2 - b2 )


tupleAdd a b =
    case ( a, b ) of
        ( ( a1, a2 ), ( b1, b2 ) ) ->
            ( a1 + b1, a2 + b2 )


toTouchMsg : Html.Events.Extra.Touch.Event -> TouchContact
toTouchMsg e =
    case e.targetTouches of
        [ touch ] ->
            OneFinger
                { identifier = touch.identifier
                , screenPos = touch.clientPos |> Point2d.fromTuple Pixels.float
                }

        _ ->
            NotOneFinger


getJoystickOrigin : Quantity.Quantity Int Pixels.Pixels -> Point2d.Point2d Pixels.Pixels ScreenCoordinates
getJoystickOrigin height =
    Point2d.xy
        (Pixels.float 130)
        (height |> Quantity.toFloatQuantity |> Quantity.minus (Pixels.float 70))


joystickSize =
    Pixels.float 20


pixelsPerJoystickWidth =
    Pixels.float 40 |> Quantity.per (Quantity.float 1)


getShootButtonLocation width height =
    Point2d.xy
        (width |> Quantity.toFloatQuantity |> Quantity.minus (Pixels.float 100))
        (height |> Quantity.toFloatQuantity |> Quantity.minus (Pixels.float 100))


getCrossHairLocation width height =
    Point2d.xy
        (width |> Quantity.toFloatQuantity |> Quantity.half)
        (height |> Quantity.toFloatQuantity |> Quantity.half)


crossHair width height =
    Geometry.Svg.circle2d
        [ Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0 }))
        , Svg.Attributes.strokeWidth (joystickSize |> Quantity.divideBy 8 |> Pixels.inPixels |> String.fromFloat)
        , Svg.Attributes.stroke "white"
        , Svg.Attributes.strokeOpacity "0.5"
        , Html.Events.onClick ShootClicked
        ]
        (getCrossHairLocation width height |> Circle2d.withRadius (joystickSize |> Quantity.divideBy 3))


capVector2d vector =
    if vector |> Vector2d.length |> Quantity.greaterThan (Quantity.float 1) then
        Vector2d.normalize vector

    else
        vector


view : Model -> Browser.Document FrontendMsg
view { playerColorTexture, width, height, cameraAngle, lightPosition, lastContact, joystickOffset, pointerCapture, world } =
    let
        playerBody =
            List.Extra.find
                (\body -> Physics.Body.data body == Player)
                (world |> Physics.World.bodies)

        otherBody =
            List.Extra.find
                (\body -> Physics.Body.data body == Dynamic)
                (world |> Physics.World.bodies)

        joystickCapped =
            capVector2d joystickOffset
    in
    { title = "elm-ball"
    , body =
        [ Html.div
            [ Html.Attributes.style "position" "fixed"
            ]
            [ Html.Lazy.lazy renderScene
                { lightPosition = lightPosition
                , playerEntity =
                    Sphere3d.atOrigin (Length.inches 1)
                        |> Scene3d.sphereWithShadow
                            (case playerColorTexture of
                                Just texture ->
                                    Scene3d.Material.texturedPbr
                                        { baseColor = texture
                                        , roughness = Scene3d.Material.constant 0
                                        , metallic = Scene3d.Material.constant 0
                                        }

                                Nothing ->
                                    Scene3d.Material.nonmetal { baseColor = Color.gray, roughness = 0 }
                            )
                , ballFrame =
                    case playerBody of
                        Just body ->
                            Physics.Body.frame body

                        Nothing ->
                            Frame3d.atOrigin
                , obstacleEntity =
                    Sphere3d.atOrigin (Length.inches 1)
                        |> Scene3d.sphereWithShadow
                            (case playerColorTexture of
                                Just texture ->
                                    Scene3d.Material.texturedPbr
                                        { baseColor = texture
                                        , roughness = Scene3d.Material.constant 0
                                        , metallic = Scene3d.Material.constant 0
                                        }

                                Nothing ->
                                    Scene3d.Material.nonmetal { baseColor = Color.gray, roughness = 0 }
                            )
                , obstacleFrame =
                    case otherBody of
                        Just body ->
                            Physics.Body.frame body

                        Nothing ->
                            Frame3d.atOrigin
                , cameraAngle = cameraAngle
                , width = width
                , height = height
                }
            ]
        , Html.div
            [ Html.Attributes.id "overlay-div"
            , Html.Attributes.style "position" "fixed"
            , Html.Events.custom "mousemove"
                (case pointerCapture of
                    PointerNotLocked ->
                        Json.Decode.fail "Mouse is not captured"

                    PointerLocked ->
                        Json.Decode.map2
                            (\a b -> { message = MouseMoved (( a, b ) |> Vector2d.fromTuple Pixels.float), preventDefault = True, stopPropagation = False })
                            (Json.Decode.field "movementX" Json.Decode.float)
                            (Json.Decode.field "movementY" Json.Decode.float)
                )
            , Html.Events.onMouseDown MouseDown
            , Html.Events.onMouseUp MouseUp
            , Html.Events.Extra.Touch.onWithOptions "touchstart"
                { preventDefault = True, stopPropagation = True }
                (\event -> TouchesChanged (toTouchMsg event))
            , Html.Events.Extra.Touch.onWithOptions "touchmove"
                { preventDefault = True, stopPropagation = True }
                (\event -> TouchesChanged (toTouchMsg event))
            , Html.Events.Extra.Touch.onWithOptions "touchend"
                { preventDefault = True, stopPropagation = True }
                (\event -> TouchesChanged (toTouchMsg event))
            ]
            [ let
                widthText =
                    width |> Pixels.inPixels |> String.fromInt

                heightText =
                    height |> Pixels.inPixels |> String.fromInt
              in
              Svg.svg
                [ Svg.Attributes.width widthText
                , Svg.Attributes.height heightText
                , Svg.Attributes.viewBox ("0 0 " ++ widthText ++ " " ++ heightText)
                ]
                (case lastContact of
                    Touch ->
                        let
                            joystickOrigin =
                                getJoystickOrigin height
                        in
                        [ Geometry.Svg.circle2d
                            [ Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                            ]
                            (Circle2d.withRadius joystickSize
                                (joystickOrigin |> Point2d.translateBy (joystickCapped |> Vector2d.at pixelsPerJoystickWidth))
                            )
                        , Geometry.Svg.circle2d
                            [ Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                            , Html.Events.Extra.Touch.onWithOptions "touchstart"
                                { preventDefault = True, stopPropagation = True }
                                (\event -> JoystickTouchChanged (toTouchMsg event))
                            , Html.Events.Extra.Touch.onWithOptions "touchmove"
                                { preventDefault = True, stopPropagation = True }
                                (\event -> JoystickTouchChanged (toTouchMsg event))
                            , Html.Events.Extra.Touch.onWithOptions "touchend"
                                { preventDefault = True, stopPropagation = True }
                                (\event -> JoystickTouchChanged (toTouchMsg event))
                            ]
                            (Circle2d.withRadius (Quantity.float 1 |> Quantity.at pixelsPerJoystickWidth) joystickOrigin)
                        , Geometry.Svg.circle2d
                            [ Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                            , Html.Events.onClick ShootClicked
                            ]
                            (Circle2d.withRadius joystickSize (getShootButtonLocation width height))
                        , crossHair width height
                        ]

                    Mouse ->
                        [ crossHair width height ]
                )
            ]
        ]
    }


renderScene { playerEntity, ballFrame, obstacleEntity, obstacleFrame, lightPosition, cameraAngle, width, height } =
    Scene3d.custom
        { lights =
            Scene3d.threeLights
                (Scene3d.Light.point (Scene3d.Light.castsShadows True)
                    { chromaticity = Scene3d.Light.fluorescent
                    , intensity = LuminousFlux.lumens 10000
                    , position = lightPosition
                    }
                )
                (Scene3d.Light.directional (Scene3d.Light.castsShadows True)
                    { chromaticity = Scene3d.Light.sunlight
                    , intensity = Illuminance.lux 50000
                    , direction = Direction3d.xyZ (Angle.turns 0.2) (Angle.turns -0.15)
                    }
                )
                (Scene3d.Light.soft
                    { upDirection = Direction3d.positiveZ
                    , chromaticity = Scene3d.Light.daylight
                    , intensityAbove = Illuminance.lux 8000
                    , intensityBelow = Illuminance.lux 2000
                    }
                )
        , camera =
            Camera3d.perspective
                { viewpoint =
                    let
                        focalPoint =
                            ballFrame |> Frame3d.originPoint
                    in
                    Viewpoint3d.lookAt
                        { eyePoint =
                            focalPoint
                                |> Point3d.translateBy
                                    (cameraAngle
                                        |> Vector3d.withLength (Length.inches 20)
                                    )
                        , focalPoint = focalPoint
                        , upDirection = Direction3d.positiveZ
                        }
                , verticalFieldOfView = Angle.degrees 45
                }
        , clipDepth = Length.centimeters 0.5
        , exposure = Scene3d.exposureValue 15
        , toneMapping = Scene3d.hableFilmicToneMapping
        , whiteBalance = Scene3d.Light.incandescent
        , antialiasing = Scene3d.multisampling
        , dimensions = ( width, height )
        , background = Scene3d.backgroundColor (Color.fromRgba { red = 0.17, green = 0.17, blue = 0.19, alpha = 1 })
        , entities =
            List.concat
                [ [ lightEntity
                        |> Scene3d.translateBy (Vector3d.from Point3d.origin lightPosition)
                  ]
                , staticEntities
                , [ playerEntity
                        |> Scene3d.placeIn ballFrame
                  , obstacleEntity
                        |> Scene3d.placeIn obstacleFrame
                  ]
                ]
        }


lightEntity =
    Sphere3d.atPoint
        (Point3d.inches 0 0 0)
        (Length.inches
            0.1
        )
        |> Scene3d.sphere
            (Scene3d.Material.emissive
                Scene3d.Light.incandescent
                (Luminance.nits
                    100000
                )
            )


worldSize =
    64


staticEntities =
    [ Scene3d.quad (Scene3d.Material.matte Color.blue)
        (Point3d.inches -worldSize -worldSize 0)
        (Point3d.inches worldSize -worldSize 0)
        (Point3d.inches worldSize worldSize 0)
        (Point3d.inches -worldSize worldSize 0)
    ]


handleArrowKey : Keyboard.Event.KeyboardEvent -> Maybe ArrowKey
handleArrowKey { altKey, ctrlKey, keyCode, metaKey, repeat, shiftKey } =
    if not (altKey || ctrlKey || metaKey || shiftKey || repeat) then
        case keyCode of
            Keyboard.Key.A ->
                Just LeftKey

            Keyboard.Key.Left ->
                Just LeftKey

            Keyboard.Key.D ->
                Just RightKey

            Keyboard.Key.Right ->
                Just RightKey

            Keyboard.Key.S ->
                Just DownKey

            Keyboard.Key.Down ->
                Just DownKey

            Keyboard.Key.W ->
                Just UpKey

            Keyboard.Key.Up ->
                Just UpKey

            _ ->
                Nothing

    else
        Nothing


subscriptions : Model -> Sub FrontendMsg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize (\x y -> WindowResized (Pixels.int x) (Pixels.int y))
        , Browser.Events.onKeyDown
            (Keyboard.Event.considerKeyboardEvent
                (\event -> Maybe.map (\key -> ArrowKeyChanged key Down) (handleArrowKey event))
            )
        , Browser.Events.onKeyUp
            (Keyboard.Event.considerKeyboardEvent
                (\event -> Maybe.map (\key -> ArrowKeyChanged key Up) (handleArrowKey event))
            )
        , Browser.Events.onAnimationFrameDelta
            (\milliseconds ->
                Tick milliseconds
            )
        , gotPointerLock
            (\value ->
                case value |> Json.decodeValue (Json.Decode.field "msg" Json.Decode.string) of
                    Ok "GotPointerLock" ->
                        GotPointerLock

                    Ok "LostPointerLock" ->
                        LostPointerLock

                    Ok _ ->
                        NoOpFrontendMsg

                    Err _ ->
                        NoOpFrontendMsg
            )
        ]


port requestPointerLock : Json.Encode.Value -> Cmd msg


port gotPointerLock : (Json.Decode.Value -> msg) -> Sub msg

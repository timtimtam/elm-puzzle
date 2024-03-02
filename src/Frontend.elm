port module Frontend exposing (app)

import Acceleration
import Angle
import Axis2d
import Axis3d
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camera3d
import Color
import Cylinder3d
import Direction2d
import Direction3d
import Direction3dWire
import Duration
import Force
import Frame3d
import Html
import Html.Attributes
import Html.Events
import Html.Events.Extra.Mouse
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
import Physics.Material
import Physics.World
import Pixels
import Plane3d
import Platform.Cmd as Cmd
import Point2d
import Point3d
import Quantity
import Review.Fix exposing (Problem(..))
import Scene3d
import Scene3d.Light
import Scene3d.Material
import SketchPlane3d
import Speed
import Sphere3d
import Svg
import Svg.Attributes
import Task
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


init : Url.Url -> Browser.Navigation.Key -> ( Model, Cmd FrontendMsg )
init _ _ =
    let
        handleResult v =
            case v of
                Err _ ->
                    NoOpFrontendMsg

                Ok vp ->
                    WindowResized vp.scene.width vp.scene.height
    in
    ( { width = 0
      , height = 0
      , cameraAngle = Direction3dWire.fromDirection3d (Maybe.withDefault Direction3d.positiveX (Direction3d.from (Point3d.inches 0 0 0) (Point3d.inches 5 -4 2)))
      , mouseButtonState = Up
      , leftKey = Up
      , rightKey = Up
      , upKey = Up
      , downKey = Up
      , joystickPosition = { x = 0, y = 0 }
      , viewAngleDelta = ( 0, 0 )
      , lightPosition = ( 3, 3, 3 )
      , touches = NotOneFinger
      , lastContact = Mouse
      , pointerCapture = PointerNotLocked
      , world =
            Physics.World.empty
                |> Physics.World.withGravity
                    (Acceleration.metersPerSecondSquared 9.80665)
                    Direction3d.negativeZ
                |> Physics.World.add
                    (Physics.Body.sphere
                        (Sphere3d.atOrigin (Length.inches 1))
                        { bodyType = Player }
                        |> Physics.Body.moveTo (Point3d.inches 0 0 5)
                        |> Physics.Body.withBehavior (Physics.Body.dynamic (Mass.kilograms 1))
                        |> Physics.Body.withMaterial (Physics.Material.custom { friction = 0.3, bounciness = 0.9 })
                        |> Physics.Body.withDamping { linear = 0.8, angular = 0.8 }
                    )
                |> Physics.World.add
                    (Physics.Body.sphere
                        (Sphere3d.atOrigin (Length.inches 1))
                        { bodyType = NotPlayer }
                        |> Physics.Body.moveTo (Point3d.inches 10 0 5)
                        |> Physics.Body.withBehavior (Physics.Body.dynamic (Mass.kilograms 5))
                        |> Physics.Body.withMaterial (Physics.Material.custom { friction = 0.3, bounciness = 0.9 })
                        |> Physics.Body.withDamping { linear = 0.8, angular = 0.8 }
                    )
                |> Physics.World.add
                    (Physics.Body.plane { bodyType = NotPlayer }
                        |> Physics.Body.moveTo (Point3d.meters 0 0 0)
                    )
      }
    , Task.attempt handleResult Browser.Dom.getViewport
    )


type PlayerCoordinates
    = PlayerCoordinates


radiansPerPixel =
    -0.004


cameraFrame3d :
    Point3d.Point3d Length.Meters RealWorldCoordinates
    -> Direction3d.Direction3d RealWorldCoordinates
    -> Maybe (Frame3d.Frame3d Length.Meters RealWorldCoordinates { defines : PlayerCoordinates })
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
    case ( msg, model.pointerCapture ) of
        ( WindowResized w h, _ ) ->
            ( { model | width = w, height = h }, Cmd.none )

        ( Tick tickMilliseconds, _ ) ->
            let
                ( rightPixels, upPixels ) =
                    model.viewAngleDelta

                world =
                    simulate
                        { joystick = Vector2d.unitless model.joystickPosition.x model.joystickPosition.y
                        , facingAngle =
                            model.cameraAngle
                                |> Direction3dWire.toDirection3d
                                |> Direction3d.azimuthIn SketchPlane3d.xy
                        }
                        (Duration.milliseconds tickMilliseconds)
                        model.world
            in
            cameraFrame3d Point3d.origin (model.cameraAngle |> Direction3dWire.toDirection3d)
                |> Maybe.map
                    (\frame ->
                        let
                            newAngle =
                                frame
                                    |> Frame3d.rotateAroundOwn Frame3d.zAxis (Angle.radians (rightPixels * radiansPerPixel))
                                    |> Frame3d.rotateAroundOwn Frame3d.xAxis (Angle.radians (upPixels * radiansPerPixel))
                                    |> Frame3d.yDirection
                        in
                        ( { model
                            | world = world
                            , viewAngleDelta = ( 0, 0 )
                            , cameraAngle = newAngle |> Direction3dWire.fromDirection3d
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        ( MouseMoved x y, PointerLocked ) ->
            ( { model
                | viewAngleDelta =
                    case model.viewAngleDelta of
                        ( a, b ) ->
                            ( a + x, b + y )
                , lastContact = Mouse
              }
            , Cmd.none
            )

        ( MouseMoved _ _, _ ) ->
            ( model
            , Cmd.none
            )

        ( MouseDown, _ ) ->
            ( { model | mouseButtonState = Down, lastContact = Mouse }, requestPointerLock Json.Encode.null )

        ( MouseUp, _ ) ->
            ( { model | mouseButtonState = Up, lastContact = Mouse }, Cmd.none )

        ( ArrowKeyChanged key state, _ ) ->
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
                    case Direction2d.from Point2d.origin (Point2d.fromUnitless { x = newJoystickX, y = newJoystickY }) of
                        Just direction ->
                            direction |> Direction2d.toVector |> Vector2d.toRecord Quantity.toFloat

                        Nothing ->
                            { x = 0, y = 0 }
            in
            ( { newModel | joystickPosition = newXY }, Cmd.none )

        ( TouchesChanged contact, _ ) ->
            let
                zeroDelta =
                    ( 0, 0 )

                delta =
                    case ( model.touches, contact ) of
                        ( OneFinger old, OneFinger new ) ->
                            if old.identifier == new.identifier then
                                tupleSubtract new.screenPos old.screenPos

                            else
                                zeroDelta

                        _ ->
                            zeroDelta

                totalDelta =
                    tupleAdd delta model.viewAngleDelta
            in
            ( { model | touches = contact, viewAngleDelta = totalDelta, lastContact = Touch }, Cmd.none )

        ( JoystickTouchChanged contact, _ ) ->
            let
                newJoystickPosition =
                    case contact of
                        OneFinger { screenPos } ->
                            case ( joystickOrigin model.height, screenPos ) of
                                ( ( jx, jy ), ( sx, sy ) ) ->
                                    { x = (sx - jx) / joystickFreedom, y = (sy - jy) / joystickFreedom }

                        NotOneFinger ->
                            { x = 0, y = 0 }
            in
            ( { model | lastContact = Touch, joystickPosition = newJoystickPosition }, Cmd.none )

        ( ShootClicked, _ ) ->
            ( model, Cmd.none )

        ( GotPointerLock, _ ) ->
            ( { model | pointerCapture = PointerLocked }, Cmd.none )

        ( LostPointerLock, _ ) ->
            ( { model | pointerCapture = PointerNotLocked }, Cmd.none )

        ( NoOpFrontendMsg, _ ) ->
            ( model, Cmd.none )


updateFromBackend msg model =
    case msg of
        FromBackendTick players ->
            ( model, Cmd.none )

        NoOpToFrontend ->
            ( model, Cmd.none )


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
    in
    world
        |> Physics.World.update
            (\body ->
                case (Physics.Body.data body).bodyType of
                    Player ->
                        let
                            direction =
                                Vector2d.direction joystickCapped
                                    |> Maybe.map
                                        (\direction2d ->
                                            Direction3d.on SketchPlane3d.xy
                                                direction2d
                                        )
                                    |> Maybe.withDefault Direction3d.z
                        in
                        body
                            |> Physics.Body.applyForce
                                (joystickCapped |> Vector2d.length |> Quantity.toFloat |> Force.newtons)
                                direction
                                (Physics.Body.originPoint body)

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
                , screenPos = touch.clientPos
                }

        _ ->
            NotOneFinger


joystickOrigin height =
    ( 130, height - 70 )


joystickSize =
    20


joystickFreedom =
    40


shootButtonLocation width height =
    ( width - 100, height - 200 )


crossHair width height =
    Svg.circle
        [ Svg.Attributes.cx (String.fromFloat (width / 2))
        , Svg.Attributes.cy (String.fromFloat (height / 2))
        , Svg.Attributes.r (String.fromFloat (joystickSize / 3))
        , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0 }))
        , Svg.Attributes.strokeWidth (String.fromFloat (joystickSize / 8))
        , Svg.Attributes.stroke "white"
        , Svg.Attributes.strokeOpacity "0.5"
        , Html.Events.onClick ShootClicked
        ]
        []


view : Model -> Browser.Document FrontendMsg
view { width, height, cameraAngle, lightPosition, lastContact, joystickPosition, pointerCapture, world } =
    let
        playerBody =
            List.Extra.find
                (\body -> (Physics.Body.data body).bodyType == Player)
                (world |> Physics.World.bodies)
    in
    { title = "elm-ball"
    , body =
        [ Html.div
            [ Html.Attributes.style "position" "fixed"
            ]
            [ Html.Lazy.lazy renderScene
                { lightPosition = lightPosition
                , cameraPosition =
                    case playerBody of
                        Just body ->
                            Physics.Body.frame body
                                |> Frame3d.originPoint
                                |> Point3d.toTuple Length.inInches

                        _ ->
                            ( 0, 0, 0 )
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
                            (\a b -> { message = MouseMoved a b, preventDefault = True, stopPropagation = False })
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
            [ Svg.svg
                [ Svg.Attributes.width (String.fromFloat width)
                , Svg.Attributes.height (String.fromFloat height)
                , Svg.Attributes.viewBox ("0 0 " ++ String.fromFloat width ++ " " ++ String.fromFloat height)
                ]
                (case lastContact of
                    _ ->
                        case joystickOrigin height of
                            ( cx, cy ) ->
                                [ Svg.circle
                                    [ Svg.Attributes.cx (String.fromFloat (cx + joystickPosition.x * joystickFreedom))
                                    , Svg.Attributes.cy (String.fromFloat (cy + joystickPosition.y * joystickFreedom))
                                    , Svg.Attributes.r (String.fromFloat joystickSize)
                                    , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                                    ]
                                    []
                                , Svg.circle
                                    [ Svg.Attributes.cx (String.fromFloat cx)
                                    , Svg.Attributes.cy (String.fromFloat cy)
                                    , Svg.Attributes.r (String.fromFloat (joystickFreedom + joystickSize / 2))
                                    , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
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
                                    []
                                , case shootButtonLocation width height of
                                    ( bx, by ) ->
                                        Svg.circle
                                            [ Svg.Attributes.cx (String.fromFloat bx)
                                            , Svg.Attributes.cy (String.fromFloat by)
                                            , Svg.Attributes.r (String.fromFloat joystickSize)
                                            , Svg.Attributes.fill (Color.toCssString (Color.fromRgba { red = 0, blue = 0, green = 0, alpha = 0.2 }))
                                            , Html.Events.onClick ShootClicked
                                            ]
                                            []
                                , crossHair width height
                                ]
                 -- Mouse ->
                 --     [ crossHair width height ]
                )
            ]
        ]
    }


renderScene { lightPosition, cameraPosition, cameraAngle, width, height } =
    Scene3d.custom
        (let
            lightPoint =
                case lightPosition of
                    ( x, y, z ) ->
                        Point3d.inches x y z
         in
         { lights =
            Scene3d.twoLights
                (Scene3d.Light.point (Scene3d.Light.castsShadows True)
                    { chromaticity = Scene3d.Light.incandescent
                    , intensity = LuminousFlux.lumens 50000
                    , position = lightPoint
                    }
                )
                (Scene3d.Light.ambient
                    { chromaticity = Scene3d.Light.incandescent
                    , intensity = Illuminance.lux 30000
                    }
                )
         , camera =
            Camera3d.perspective
                { viewpoint =
                    let
                        ( x, y, z ) =
                            cameraPosition

                        focalPoint =
                            Point3d.inches x y z
                    in
                    Viewpoint3d.lookAt
                        { eyePoint =
                            focalPoint
                                |> Point3d.translateBy
                                    (cameraAngle
                                        |> Direction3dWire.toDirection3d
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
         , dimensions = ( Pixels.int (round width), Pixels.int (round height) )
         , background = Scene3d.backgroundColor (Color.fromRgba { red = 0.17, green = 0.17, blue = 0.19, alpha = 1 })
         , entities =
            List.concat
                [ [ lightEntity
                        |> Scene3d.translateBy (Vector3d.fromTuple Length.inches lightPosition)
                  ]
                , staticEntities
                , [ ballEntity
                        |> Scene3d.translateBy (Vector3d.fromTuple Length.inches cameraPosition)
                  ]
                ]
         }
        )


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


ballEntity =
    Sphere3d.atPoint
        (Point3d.inches 0 0 0)
        (Length.inches
            1
        )
        |> Scene3d.sphereWithShadow
            (Scene3d.Material.metal
                { baseColor = Color.rgb 1.0 0.766 0.336
                , roughness = 0.4
                }
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
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\x y -> WindowResized (toFloat x) (toFloat y))
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

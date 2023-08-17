module Frontend exposing (app)

import Angle
import Axis3d
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camera3d
import Color
import Cylinder3d
import Direction2d exposing (Direction2d)
import Direction3d
import Direction3dWire
import Html
import Html.Attributes
import Html.Events
import Html.Events.Extra.Touch
import Illuminance
import Json.Decode
import Keyboard.Event
import Keyboard.Key
import Lamdera
import Length
import Luminance
import LuminousFlux
import Pixels
import Plane3d
import Point3d
import Quantity
import Scene3d
import Scene3d.Light
import Scene3d.Material
import Sphere3d
import Svg
import Svg.Attributes
import Task
import Types exposing (ArrowKey(..), ButtonState(..), ContactType(..), FrontendModel, FrontendMsg(..), TouchContact(..))
import Url
import Vector2d exposing (Vector2d)
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
        , updateFromBackend = \_ model -> ( model, Cmd.none )
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
      , cameraAngle = Direction3dWire.fromDirection3d (Maybe.withDefault Direction3d.positiveX (Direction3d.from (Point3d.inches 5 -4 2) (Point3d.inches 2 2 2)))
      , cameraPosition = ( 5, -4, 2 )
      , mouseButtonState = Up
      , leftKey = Up
      , rightKey = Up
      , upKey = Up
      , downKey = Up
      , joystickPosition = ( 0, 0 )
      , viewAngleDelta = ( 0, 0 )
      , lightPosition = ( 3, 3, 3 )
      , touches = NotOneFinger
      , lastContact = Mouse
      }
    , Task.attempt handleResult Browser.Dom.getViewport
    )


update : FrontendMsg -> Model -> ( Model, Cmd msg )
update msg model =
    case ( msg, model.mouseButtonState ) of
        ( WindowResized w h, _ ) ->
            ( { model | width = w, height = h }, Cmd.none )

        ( Tick delta, _ ) ->
            if inputsUnchanged model then
                ( model, Cmd.none )

            else
                let
                    scaledDelta =
                        delta * 0.005

                    cameraUp =
                        Direction3d.positiveZ

                    cameraAngle =
                        Direction3dWire.toDirection3d model.cameraAngle

                    cameraLeft =
                        Vector3d.direction
                            (Vector3d.cross
                                (Direction3d.toVector cameraUp)
                                (Direction3d.toVector cameraAngle)
                            )
                            |> Maybe.map Direction3d.toVector

                    cameraLeftDirection =
                        cameraLeft |> Maybe.andThen Vector3d.direction

                    newCameraPosition =
                        -- Move the camera based on the arrow keys
                        let
                            positionVector =
                                Vector3d.fromTuple Quantity.float model.cameraPosition

                            cameraAngleXY =
                                Direction3d.projectOnto Plane3d.xy (Direction3dWire.toDirection3d model.cameraAngle)
                        in
                        case ( cameraAngleXY, cameraLeft ) of
                            ( Just angleXY, Just left ) ->
                                let
                                    forward =
                                        Direction3d.toVector angleXY
                                in
                                Vector3d.sum
                                    [ positionVector
                                    , case model.joystickPosition of
                                        ( px, py ) ->
                                            Vector3d.unitless (px / 10) (-py / 10) 0
                                    ]
                                    |> Vector3d.toTuple Quantity.toFloat

                            _ ->
                                model.cameraPosition

                    newAngle =
                        case model.viewAngleDelta of
                            ( x, y ) ->
                                case cameraLeftDirection of
                                    Just left ->
                                        cameraAngle
                                            |> Direction3d.rotateAround
                                                (Axis3d.through Point3d.origin cameraUp)
                                                (Angle.radians (-4 * x / model.width))
                                            |> Direction3d.rotateAround
                                                (Axis3d.through Point3d.origin left)
                                                (Angle.radians (-4 * y / model.height))

                                    Nothing ->
                                        cameraAngle
                in
                ( { model
                    | cameraPosition = newCameraPosition
                    , cameraAngle = Direction3dWire.fromDirection3d newAngle
                    , viewAngleDelta = ( 0, 0 )
                  }
                , Cmd.none
                )

        ( MouseMoved x y, Down ) ->
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
            ( model, Cmd.none )

        ( MouseDown, _ ) ->
            ( { model | mouseButtonState = Down, lastContact = Mouse }, Cmd.none )

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
                            -1

                        ( Down, Up ) ->
                            1

                        _ ->
                            0
            in
            ( { newModel | joystickPosition = ( newJoystickX, newJoystickY ) }, Cmd.none )

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
                                    let
                                        newX =
                                            (sx - jx) / joystickFreedom

                                        newY =
                                            (sy - jy) / joystickFreedom

                                        vector =
                                            Vector2d.unitless newX newY
                                    in
                                    if Quantity.toFloat (Vector2d.length vector) > 1 then
                                        case Vector2d.direction vector |> Maybe.map Direction2d.unwrap of
                                            Just { x, y } ->
                                                ( x, y )

                                            Nothing ->
                                                ( 0, 0 )

                                    else
                                        ( newX, newY )

                        NotOneFinger ->
                            ( 0, 0 )
            in
            ( { model | lastContact = Touch, joystickPosition = newJoystickPosition }, Cmd.none )

        ( ShootClicked, _ ) ->
            ( model, Cmd.none )

        ( NoOpFrontendMsg, _ ) ->
            ( model, Cmd.none )


tupleSubtract a b =
    case ( a, b ) of
        ( ( a1, a2 ), ( b1, b2 ) ) ->
            ( a1 - b1, a2 - b2 )


tupleAdd a b =
    case ( a, b ) of
        ( ( a1, a2 ), ( b1, b2 ) ) ->
            ( a1 + b1, a2 + b2 )


inputsUnchanged { viewAngleDelta, joystickPosition } =
    (case viewAngleDelta of
        ( dx, dy ) ->
            Basics.abs dx < 0.0001 && Basics.abs dy < 0.0001
    )
        && (case joystickPosition of
                ( dx, dy ) ->
                    Basics.abs dx < 0.0001 && Basics.abs dy < 0.0001
           )


toTouchMsg e =
    case e.touches of
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


view : Model -> Browser.Document FrontendMsg
view { width, height, cameraAngle, cameraPosition, lightPosition, lastContact, joystickPosition } =
    { title = "Hello"
    , body =
        [ Html.div
            [ Html.Attributes.style "position" "fixed"
            , Html.Attributes.style "z-index" "2"
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
                    Touch ->
                        case joystickOrigin height of
                            ( cx, cy ) ->
                                [ case joystickPosition of
                                    ( px, py ) ->
                                        Svg.circle
                                            [ Svg.Attributes.cx (String.fromFloat (cx + px * joystickFreedom))
                                            , Svg.Attributes.cy (String.fromFloat (cy + py * joystickFreedom))
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
                                ]

                    Mouse ->
                        []
                )
            ]
        , Html.div
            []
            [ Scene3d.custom
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
                            case cameraPosition of
                                ( x, y, z ) ->
                                    Viewpoint3d.lookAt
                                        { eyePoint =
                                            Point3d.inches x y z
                                        , focalPoint =
                                            Point3d.translateIn
                                                (Direction3dWire.toDirection3d cameraAngle)
                                                (Quantity.Quantity 1)
                                                (Point3d.inches x y z)
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
                        [ [ lightEntity |> Scene3d.translateBy (Vector3d.fromTuple Length.inches lightPosition)
                          ]
                        , staticEntities
                        ]
                 }
                )
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
    [ Cylinder3d.from
        Point3d.origin
        (Point3d.inches 0 0 1)
        (Length.inches
            0.5
        )
        |> Maybe.map
            (Scene3d.cylinderWithShadow
                (Scene3d.Material.matte Color.blue)
            )
        |> Maybe.withDefault Scene3d.nothing
    , Cylinder3d.from
        (Point3d.inches 2 2 0.5)
        (Point3d.inches 2 2 1)
        (Length.inches
            0.5
        )
        |> Maybe.map
            (Scene3d.cylinderWithShadow
                (Scene3d.Material.matte Color.gray)
            )
        |> Maybe.withDefault Scene3d.nothing
    , Scene3d.quad (Scene3d.Material.matte Color.blue)
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
        , Browser.Events.onMouseMove
            (case model.mouseButtonState of
                Up ->
                    Json.Decode.fail "Mouse is not down"

                Down ->
                    Json.Decode.map2
                        MouseMoved
                        (Json.Decode.field "movementX" Json.Decode.float)
                        (Json.Decode.field "movementY" Json.Decode.float)
            )
        , Browser.Events.onMouseDown (Json.Decode.succeed MouseDown)
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseUp)
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
        ]

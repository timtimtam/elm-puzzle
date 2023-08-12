module Frontend exposing (app)

-- import Json.Decode

import Angle
import Axis3d
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Camera3d
import Color
import Cylinder3d
import Direction3d
import Direction3dWire
import Html
import Html.Attributes
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
import Task
import Types exposing (ArrowKey(..), ButtonState(..), FrontendModel, FrontendMsg(..))
import Url
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
      , cameraAngle = Direction3dWire.fromDirection3d Direction3d.positiveY
      , cameraPosition = ( 2, 2, 2 )
      , mouseButtonState = Up
      , leftKey = Up
      , rightKey = Up
      , upKey = Up
      , downKey = Up
      , mouseDelta = ( 0, 0 )
      , lightPosition = ( 3, 3, 3 )
      }
    , Task.attempt handleResult Browser.Dom.getViewport
    )


update : FrontendMsg -> Model -> ( Model, Cmd msg )
update msg model =
    case ( msg, model.mouseButtonState ) of
        ( WindowResized w h, _ ) ->
            ( { model | width = w, height = h }, Cmd.none )

        ( Tick delta, _ ) ->
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
                            (case ( model.upKey, model.downKey ) of
                                ( Up, Down ) ->
                                    Vector3d.multiplyBy -scaledDelta forward

                                ( Down, Up ) ->
                                    Vector3d.multiplyBy scaledDelta forward

                                _ ->
                                    Vector3d.zero
                            )
                                |> Vector3d.plus
                                    (case ( model.leftKey, model.rightKey ) of
                                        ( Up, Down ) ->
                                            Vector3d.scaleBy scaledDelta left

                                        ( Down, Up ) ->
                                            Vector3d.scaleBy -scaledDelta left

                                        _ ->
                                            Vector3d.zero
                                    )
                                |> Vector3d.plus positionVector
                                |> Vector3d.toTuple Quantity.toFloat

                        _ ->
                            model.cameraPosition

                newAngle =
                    case model.mouseDelta of
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
                , mouseDelta = ( 0, 0 )
              }
            , Cmd.none
            )

        ( MouseMoved x y, Down ) ->
            ( { model
                | mouseDelta =
                    case model.mouseDelta of
                        ( a, b ) ->
                            ( a + x, b + y )
              }
            , Cmd.none
            )

        ( MouseMoved _ _, _ ) ->
            ( model, Cmd.none )

        ( MouseDown, _ ) ->
            ( { model | mouseButtonState = Down }, Cmd.none )

        ( MouseUp, _ ) ->
            ( { model | mouseButtonState = Up }, Cmd.none )

        ( ArrowKeyChanged key state, _ ) ->
            case key of
                UpKey ->
                    ( { model | upKey = state }, Cmd.none )

                DownKey ->
                    ( { model | downKey = state }, Cmd.none )

                LeftKey ->
                    ( { model | leftKey = state }, Cmd.none )

                RightKey ->
                    ( { model | rightKey = state }, Cmd.none )

        ( NoOpFrontendMsg, _ ) ->
            ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view { width, height, cameraAngle, cameraPosition, lightPosition } =
    { title = "Hello"
    , body =
        [ Html.div
            [ Html.Attributes.style "position" "fixed"
            , Html.Attributes.style "height" "100vh"
            , Html.Attributes.style "overflow" "hidden"
            ]
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
                            , intensity = Illuminance.lux 10000
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
                                        , focalPoint = Point3d.translateIn (Direction3dWire.toDirection3d cameraAngle) (Quantity.Quantity 1) (Point3d.inches x y z)
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
                    (lightEntity |> Scene3d.translateBy (Vector3d.fromTuple Length.inches lightPosition)) :: staticEntities
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
        (Point3d.centimeters 0 0 0)
        (Point3d.centimeters 10 0 0)
        (Point3d.centimeters 10 10 0)
        (Point3d.centimeters 0 10 0)
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

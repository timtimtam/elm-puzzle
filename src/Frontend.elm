module Frontend exposing (..)

-- import Json.Decode

import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode exposing (Decoder, field, float, int)
import Lamdera
import Lamdera.Json as Json
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Task
import Types exposing (..)
import Url
import WebGL exposing (antialias, clearColor)
import WebGL.Settings exposing (FaceMode, back, cullFace)
import WebGL.Texture as Texture exposing (Texture)


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = \_ -> NoOpFrontendMsg
        , onUrlChange = \_ -> NoOpFrontendMsg
        , update =
            \msg model ->
                case ( msg, model.mouseButtonState ) of
                    ( WindowResized w h, _ ) ->
                        ( { model | width = w, height = h }, Cmd.none )

                    ( MouseMoved x y, Down ) ->
                        let
                            cameraLeft =
                                Math.Vector3.cross model.cameraUp model.cameraAngle

                            newAngle =
                                Math.Vector3.normalize
                                    (model.cameraAngle
                                        |> Math.Matrix4.transform
                                            (Math.Matrix4.mul
                                                (Math.Matrix4.makeRotate
                                                    (-8 * x / model.width)
                                                    model.cameraUp
                                                )
                                                (Math.Matrix4.makeRotate
                                                    (-8 * y / model.height)
                                                    cameraLeft
                                                )
                                            )
                                    )

                            newUp =
                                Math.Vector3.normalize
                                    (Math.Vector3.negate
                                        (Math.Vector3.cross cameraLeft newAngle)
                                    )
                        in
                        ( { model | cameraAngle = newAngle, cameraUp = newUp }, Cmd.none )

                    ( MouseMoved _ _, _ ) ->
                        ( model, Cmd.none )

                    ( MouseDown, _ ) ->
                        ( { model | mouseButtonState = Down }, Cmd.none )

                    ( MouseUp, _ ) ->
                        ( { model | mouseButtonState = Up }, Cmd.none )

                    ( NoOpFrontendMsg, _ ) ->
                        ( model, Cmd.none )
        , updateFromBackend = \_ model -> ( model, Cmd.none )
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Browser.Events.onResize (\x y -> WindowResized (toFloat x) (toFloat y))
                    , Browser.Events.onMouseMove
                        (Json.Decode.map2
                            MouseMoved
                            (field "movementX" float)
                            (field "movementY" float)
                        )
                    , Browser.Events.onMouseDown (Json.Decode.succeed MouseDown)
                    , Browser.Events.onMouseUp (Json.Decode.succeed MouseUp)
                    ]
        , view = view
        }


init _ key =
    let
        handleResult v =
            case v of
                Err err ->
                    NoOpFrontendMsg

                Ok vp ->
                    WindowResized vp.scene.width vp.scene.height
    in
    ( { width = 0
      , height = 0
      , cameraAngle = vec3 1 1 0
      , cameraDistance = 10
      , cameraUp = vec3 0 1 0
      , mouseButtonState = Up
      }
    , Task.attempt handleResult Browser.Dom.getViewport
    )



-- view : Float -> Html msg


view { width, height, cameraAngle, cameraDistance, cameraUp } =
    { title = "Hello"
    , body =
        [ WebGL.toHtmlWith
            [ antialias, clearColor 0.2 0.2 0.3 1 ]
            [ Attr.width (round width)
            , Attr.height (round height)
            , Attr.style "display" "block"
            , Attr.style "background-color" "#292C34"
            ]
            [ WebGL.entityWith [ cullFace back ]
                vertexShader
                fragmentShader
                manualCrates
                { perspective = perspective (width / height) cameraAngle cameraDistance cameraUp }
            ]
        ]
    }


perspective ratio cameraAngle cameraDistance cameraUp =
    Math.Matrix4.mul
        (Math.Matrix4.makePerspective 45 ratio 0.1 100)
        (Math.Matrix4.makeLookAt
            (Math.Vector3.scale cameraDistance (Math.Vector3.normalize cameraAngle))
            (vec3 0.5 0.5 0.5)
            cameraUp
        )



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


manualCrates : WebGL.Mesh Vertex
manualCrates =
    WebGL.indexedTriangles
        [ { position = vec3 0 0 0, color = vec3 0 0 0 }
        , { position = vec3 1 0 0, color = vec3 1 0 0 }
        , { position = vec3 1 1 0, color = vec3 1 1 0 }
        , { position = vec3 0 1 0, color = vec3 0 1 0 }
        , { position = vec3 0 0 1, color = vec3 0 0 1 }
        , { position = vec3 1 0 1, color = vec3 1 0 1 }
        , { position = vec3 1 1 1, color = vec3 1 1 1 }
        , { position = vec3 0 1 1, color = vec3 0 1 1 }
        ]
        [ ( 1, 0, 2 )
        , ( 2, 0, 3 )
        , ( 0, 1, 4 )
        , ( 4, 1, 5 )
        , ( 1, 2, 5 )
        , ( 5, 2, 6 )
        , ( 2, 3, 6 )
        , ( 6, 3, 7 )
        , ( 3, 0, 7 )
        , ( 7, 0, 4 )
        , ( 4, 5, 7 )
        , ( 7, 5, 6 )
        ]



-- 3D drawing of the vertexes:
--
--                7-------6
--               /|      /|
--              / |     / |
--             4--|----5  |
--             |  3----|--2
--             | /     | /
--             |/      |/
--             0-------1
--
-- The triangles are drawn counter-clockwise, 2 triangles per face.


crate : WebGL.Mesh Vertex
crate =
    [ ( 0, 0 ), ( 90, 0 ), ( 180, 0 ), ( 270, 0 ), ( 0, 90 ), ( 0, -90 ) ]
        |> List.concatMap rotatedSquare
        |> WebGL.triangles


rotatedSquare : ( Float, Float ) -> List ( Vertex, Vertex, Vertex )
rotatedSquare ( angleXZ, angleYZ ) =
    let
        transformMat =
            Math.Matrix4.mul
                (Math.Matrix4.makeRotate (degrees angleXZ) Math.Vector3.j)
                (Math.Matrix4.makeRotate (degrees angleYZ) Math.Vector3.i)

        transform vertex =
            { vertex
                | position =
                    Math.Matrix4.transform transformMat vertex.position
            }

        transformTriangle ( a, b, c ) =
            ( transform a, transform b, transform c )
    in
    List.map transformTriangle square


square : List ( Vertex, Vertex, Vertex )
square =
    let
        topLeft =
            Vertex (vec3 -1 1 1) (vec3 1 1 0)

        topRight =
            Vertex (vec3 1 1 1) (vec3 1 0 1)

        bottomLeft =
            Vertex (vec3 -1 -1 1) (vec3 0 0 0)

        bottomRight =
            Vertex (vec3 1 -1 1) (vec3 0 1 1)
    in
    [ ( topLeft, topRight, bottomLeft )
    , ( bottomLeft, topRight, bottomRight )
    ]



-- Shaders


type alias Uniforms =
    { perspective : Mat4 }


vertexShader : WebGL.Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        varying vec3 vcolor;

        void main () {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;
        }

    |]


fragmentShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|

        precision mediump float;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }

    |]

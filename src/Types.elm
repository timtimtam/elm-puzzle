module Types exposing (..)

import Color
import Direction3dWire exposing (Direction3dWire)
import Physics.Body
import Physics.Coordinates
import Physics.World
import Scene3d.Material
import WebGL.Texture


type ButtonState
    = Up
    | Down


type ScreenCoordinates
    = ScreenCoordinates


type TouchContact
    = OneFinger { identifier : Int, screenPos : ( Float, Float ) }
    | NotOneFinger


type PointerCapture
    = PointerLocked
    | PointerNotLocked


type BodyType
    = Static
    | Dynamic
    | Player


type alias WorldData =
    BodyType


type FrontendModel
    = Loading
        { colorTexture : Maybe (Scene3d.Material.Texture Color.Color)
        , roughnessTexture : Maybe (Scene3d.Material.Texture Float)
        , width : Float
        , height : Float
        }
    | Loaded
        { colorTexture : Scene3d.Material.Texture Color.Color
        , roughnessTexture : Scene3d.Material.Texture Float
        , width : Float
        , height : Float
        , cameraAngle : Direction3dWire Physics.Coordinates.WorldCoordinates
        , leftKey : ButtonState
        , rightKey : ButtonState
        , upKey : ButtonState
        , downKey : ButtonState
        , mouseButtonState : ButtonState
        , touches : TouchContact
        , world : Physics.World.World WorldData
        , joystickPosition : { x : Float, y : Float }
        , viewAngleDelta : ( Float, Float )
        , lightPosition : ( Float, Float, Float )
        , lastContact : ContactType
        , pointerCapture : PointerCapture
        }
    | Errored String


type ContactType
    = Touch
    | Mouse


type alias BackendModel =
    { players : List { sessionId : String, id : Int, x : Float, y : Float, z : Float }
    , nextPlayerId : Int
    }


type ArrowKey
    = UpKey
    | DownKey
    | LeftKey
    | RightKey


type FrontendMsg
    = WindowResized Float Float
    | Tick Float
    | MouseMoved Float Float
    | MouseDown
    | MouseUp
    | ArrowKeyChanged ArrowKey ButtonState
    | TouchesChanged TouchContact
    | JoystickTouchChanged TouchContact
    | ShootClicked
    | GotPointerLock
    | LostPointerLock
    | GotColorTexture (Result WebGL.Texture.Error (Scene3d.Material.Texture Color.Color))
    | GotRoughnessTexture (Result WebGL.Texture.Error (Scene3d.Material.Texture Float))
    | NoOpFrontendMsg


type ToBackend
    = FromFrontendTick { joystick : ( Float, Float ), rotation : ( Float, Float ) }
    | NoOpToBackend


type BackendMsg
    = ClientConnected String String
    | NoOpBackendMsg


type ToFrontend
    = FromBackendTick (List { id : String, x : Float, y : Float, z : Float })
    | NoOpToFrontend

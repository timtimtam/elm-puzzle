module Evergreen.V28.Types exposing (..)

import Color
import Evergreen.V28.Direction3d
import Evergreen.V28.Physics.Coordinates
import Evergreen.V28.Physics.World
import Evergreen.V28.Scene3d.Material
import WebGL.Texture


type ButtonState
    = Up
    | Down


type TouchContact
    = OneFinger
        { identifier : Int
        , screenPos : ( Float, Float )
        }
    | NotOneFinger


type BodyType
    = Static
    | Dynamic
    | Player


type alias WorldData =
    BodyType


type ContactType
    = Touch
    | Mouse


type PointerCapture
    = PointerLocked
    | PointerNotLocked


type alias FrontendModel =
    { width : Float
    , height : Float
    , cameraAngle : Evergreen.V28.Direction3d.Direction3d Evergreen.V28.Physics.Coordinates.WorldCoordinates
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , mouseButtonState : ButtonState
    , touches : TouchContact
    , world : Evergreen.V28.Physics.World.World WorldData
    , joystickPosition :
        { x : Float
        , y : Float
        }
    , viewAngleDelta : ( Float, Float )
    , lightPosition : ( Float, Float, Float )
    , lastContact : ContactType
    , pointerCapture : PointerCapture
    , playerColorTexture : Maybe (Evergreen.V28.Scene3d.Material.Texture Color.Color)
    , playerRoughnessTexture : Maybe (Evergreen.V28.Scene3d.Material.Texture Float)
    }


type alias BackendModel =
    { players :
        List
            { sessionId : String
            , id : Int
            , x : Float
            , y : Float
            , z : Float
            }
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
    | GotColorTexture (Result WebGL.Texture.Error (Evergreen.V28.Scene3d.Material.Texture Color.Color))
    | GotRoughnessTexture (Result WebGL.Texture.Error (Evergreen.V28.Scene3d.Material.Texture Float))
    | NoOpFrontendMsg


type ToBackend
    = FromFrontendTick
        { joystick : ( Float, Float )
        , rotation : ( Float, Float )
        }
    | NoOpToBackend


type BackendMsg
    = ClientConnected String String
    | NoOpBackendMsg


type ToFrontend
    = FromBackendTick
        (List
            { id : String
            , x : Float
            , y : Float
            , z : Float
            }
        )
    | NoOpToFrontend

module Evergreen.V22.Types exposing (..)

import Evergreen.V22.Direction3dWire
import Evergreen.V22.Physics.World


type RealWorldCoordinates
    = RealWorldCoordinates


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
    = NotPlayer
    | Player


type alias WorldData =
    { bodyType : BodyType
    }


type ContactType
    = Touch
    | Mouse


type PointerCapture
    = PointerLocked
    | PointerNotLocked


type alias FrontendModel =
    { width : Float
    , height : Float
    , cameraAngle : Evergreen.V22.Direction3dWire.Direction3dWire RealWorldCoordinates
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , mouseButtonState : ButtonState
    , touches : TouchContact
    , world : Evergreen.V22.Physics.World.World WorldData
    , joystickPosition :
        { x : Float
        , y : Float
        }
    , viewAngleDelta : ( Float, Float )
    , lightPosition : ( Float, Float, Float )
    , lastContact : ContactType
    , pointerCapture : PointerCapture
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

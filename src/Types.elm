module Types exposing (..)

import Direction3dWire exposing (Direction3dWire)
import Physics.Body exposing (velocity)
import Physics.World


type ButtonState
    = Up
    | Down


type RealWorldCoordinates
    = RealWorldCoordinates


type ScreenCoordinates
    = ScreenCoordinates


type TouchContact
    = OneFinger { identifier : Int, screenPos : ( Float, Float ) }
    | NotOneFinger


type PointerCapture
    = PointerLocked
    | PointerNotLocked


type BodyType
    = NotPlayer
    | Player


type alias WorldData =
    { bodyType : BodyType }


type alias FrontendModel =
    { width : Float
    , height : Float
    , cameraAngle : Direction3dWire RealWorldCoordinates
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

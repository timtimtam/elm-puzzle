module Evergreen.V4.Types exposing (..)

import Evergreen.V4.Direction3dWire


type ButtonState
    = Up
    | Down


type RealWorldCoordinates
    = RealWorldCoordinates


type alias FrontendModel =
    { width : Float
    , height : Float
    , mousePosition : ( Float, Float )
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , cameraAngle : Evergreen.V4.Direction3dWire.Direction3dWire RealWorldCoordinates
    , cameraPosition : ( Float, Float, Float )
    , mouseButtonState : ButtonState
    , lightPosition : ( Float, Float, Float )
    }


type alias BackendModel =
    { message : String
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
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend

module Evergreen.V1.Types exposing (..)

import Math.Vector3


type MouseButtonState
    = Up
    | Down


type alias FrontendModel =
    { width : Float
    , height : Float
    , cameraAngle : Math.Vector3.Vec3
    , cameraDistance : Float
    , cameraUp : Math.Vector3.Vec3
    , mouseButtonState : MouseButtonState
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = WindowResized Float Float
    | MouseMoved Float Float
    | MouseDown
    | MouseUp
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend

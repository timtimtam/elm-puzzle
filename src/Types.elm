module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Html.Attributes exposing (height)
import Json.Decode
import Math.Vector3 exposing (Vec3)
import Url exposing (Url)


type MouseButtonState
    = Up
    | Down


type alias FrontendModel =
    { width : Float
    , height : Float
    , cameraAngle : Vec3
    , cameraDistance : Float
    , cameraUp : Vec3
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

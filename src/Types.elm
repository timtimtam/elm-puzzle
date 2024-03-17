module Types exposing (..)

import Color
import Direction3d
import Element
import Length
import Physics.Coordinates
import Physics.World
import Pixels
import Point2d
import Quantity
import Scene3d.Material
import Vector2d
import WebGL.Texture


type ButtonState
    = Up
    | Down


type ScreenCoordinates
    = ScreenCoordinates


type TouchContact
    = OneFinger { identifier : Int, screenPos : Point2d.Point2d Pixels.Pixels ScreenCoordinates }
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


type alias FrontendModel =
    { width : Quantity.Quantity Int Pixels.Pixels
    , height : Quantity.Quantity Int Pixels.Pixels
    , cameraAngle : Direction3d.Direction3d Physics.Coordinates.WorldCoordinates
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , mouseButtonState : ButtonState
    , touches : TouchContact
    , world : Physics.World.World WorldData
    , joystickOffset : Vector2d.Vector2d Quantity.Unitless ScreenCoordinates
    , viewPivotDelta : Vector2d.Vector2d Pixels.Pixels ScreenCoordinates
    , lightPosition : ( Float, Float, Float )
    , lastContact : ContactType
    , pointerCapture : PointerCapture
    , playerColorTexture : Maybe (Scene3d.Material.Texture Color.Color)
    , playerRoughnessTexture : Maybe (Scene3d.Material.Texture Float)
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
    = WindowResized (Quantity.Quantity Int Pixels.Pixels) (Quantity.Quantity Int Pixels.Pixels)
    | Tick Float
    | MouseMoved (Vector2d.Vector2d Pixels.Pixels ScreenCoordinates)
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

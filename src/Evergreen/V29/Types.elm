module Evergreen.V29.Types exposing (..)

import Color
import Evergreen.V29.Direction3d
import Evergreen.V29.Physics.Coordinates
import Evergreen.V29.Physics.World
import Evergreen.V29.Point2d
import Evergreen.V29.Point3d
import Evergreen.V29.Scene3d.Material
import Evergreen.V29.Vector2d
import Length
import Pixels
import Quantity
import WebGL.Texture


type ButtonState
    = Up
    | Down


type ScreenCoordinates
    = ScreenCoordinates


type TouchContact
    = OneFinger
        { identifier : Int
        , screenPos : Evergreen.V29.Point2d.Point2d Pixels.Pixels ScreenCoordinates
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
    { width : Quantity.Quantity Int Pixels.Pixels
    , height : Quantity.Quantity Int Pixels.Pixels
    , cameraAngle : Evergreen.V29.Direction3d.Direction3d Evergreen.V29.Physics.Coordinates.WorldCoordinates
    , leftKey : ButtonState
    , rightKey : ButtonState
    , upKey : ButtonState
    , downKey : ButtonState
    , mouseButtonState : ButtonState
    , touches : TouchContact
    , world : Evergreen.V29.Physics.World.World WorldData
    , joystickOffset : Evergreen.V29.Vector2d.Vector2d Quantity.Unitless ScreenCoordinates
    , viewPivotDelta : Evergreen.V29.Vector2d.Vector2d Pixels.Pixels ScreenCoordinates
    , lightPosition : Evergreen.V29.Point3d.Point3d Length.Meters Evergreen.V29.Physics.Coordinates.WorldCoordinates
    , lastContact : ContactType
    , pointerCapture : PointerCapture
    , playerColorTexture : Maybe (Evergreen.V29.Scene3d.Material.Texture Color.Color)
    , playerRoughnessTexture : Maybe (Evergreen.V29.Scene3d.Material.Texture Float)
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
    = WindowResized (Quantity.Quantity Int Pixels.Pixels) (Quantity.Quantity Int Pixels.Pixels)
    | Tick Float
    | MouseMoved (Evergreen.V29.Vector2d.Vector2d Pixels.Pixels ScreenCoordinates)
    | MouseDown
    | MouseUp
    | ArrowKeyChanged ArrowKey ButtonState
    | TouchesChanged TouchContact
    | JoystickTouchChanged TouchContact
    | ShootClicked
    | GotPointerLock
    | LostPointerLock
    | GotColorTexture (Result WebGL.Texture.Error (Evergreen.V29.Scene3d.Material.Texture Color.Color))
    | GotRoughnessTexture (Result WebGL.Texture.Error (Evergreen.V29.Scene3d.Material.Texture Float))
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

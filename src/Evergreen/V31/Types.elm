module Evergreen.V31.Types exposing (..)

import AngularSpeed
import Color
import Duration
import Evergreen.V31.Direction3d
import Evergreen.V31.Frame3d
import Evergreen.V31.Physics.Coordinates
import Evergreen.V31.Physics.World
import Evergreen.V31.Point2d
import Evergreen.V31.Point3d
import Evergreen.V31.Scene3d.Material
import Evergreen.V31.Vector2d
import Evergreen.V31.Vector3d
import Lamdera
import Length
import Pixels
import Quantity
import Set
import Speed
import Time
import WebGL.Texture


type ButtonState
    = Up
    | Down


type ScreenCoordinates
    = ScreenCoordinates


type TouchContact
    = OneFinger
        { identifier : Int
        , screenPos : Evergreen.V31.Point2d.Point2d Pixels.Pixels ScreenCoordinates
        }
    | NotOneFinger


type WorldData
    = Static
    | Player
        { id : Int
        , movement : Evergreen.V31.Vector2d.Vector2d Quantity.Unitless Evergreen.V31.Physics.Coordinates.WorldCoordinates
        }


type ContactType
    = Touch
    | Mouse


type PointerCapture
    = PointerLocked
    | PointerNotLocked


type FrontendModel
    = Lobby
        { name : String
        , width : Quantity.Quantity Int Pixels.Pixels
        , height : Quantity.Quantity Int Pixels.Pixels
        , playerColorTexture : Maybe (Evergreen.V31.Scene3d.Material.Texture Color.Color)
        , playerRoughnessTexture : Maybe (Evergreen.V31.Scene3d.Material.Texture Float)
        }
    | Joined
        { id : Int
        , name : String
        , width : Quantity.Quantity Int Pixels.Pixels
        , height : Quantity.Quantity Int Pixels.Pixels
        , cameraAngle : Evergreen.V31.Direction3d.Direction3d Evergreen.V31.Physics.Coordinates.WorldCoordinates
        , leftKey : ButtonState
        , rightKey : ButtonState
        , upKey : ButtonState
        , downKey : ButtonState
        , mouseButtonState : ButtonState
        , touches : TouchContact
        , world : Evergreen.V31.Physics.World.World WorldData
        , joystickOffset : Evergreen.V31.Vector2d.Vector2d Quantity.Unitless ScreenCoordinates
        , viewPivotDelta : Evergreen.V31.Vector2d.Vector2d Pixels.Pixels ScreenCoordinates
        , lightPosition : Evergreen.V31.Point3d.Point3d Length.Meters Evergreen.V31.Physics.Coordinates.WorldCoordinates
        , lastContact : ContactType
        , pointerCapture : PointerCapture
        , playerColorTexture : Maybe (Evergreen.V31.Scene3d.Material.Texture Color.Color)
        , playerRoughnessTexture : Maybe (Evergreen.V31.Scene3d.Material.Texture Float)
        }


type BackendWorldData
    = BackendStatic
    | BackendPlayer
        { id : Int
        , movement : Evergreen.V31.Vector2d.Vector2d Quantity.Unitless Evergreen.V31.Physics.Coordinates.WorldCoordinates
        , sessionId : Lamdera.SessionId
        , clients : Set.Set Lamdera.ClientId
        }


type alias BackendModel =
    { world : Evergreen.V31.Physics.World.World BackendWorldData
    , previousTick :
        Maybe
            { previousTickTime : Time.Posix
            , previousUpdateTime : Time.Posix
            }
    , nextId : Int
    }


type ArrowKey
    = UpKey
    | DownKey
    | LeftKey
    | RightKey


type FrontendMsg
    = WindowResized (Quantity.Quantity Int Pixels.Pixels) (Quantity.Quantity Int Pixels.Pixels)
    | Tick Duration.Duration
    | MouseMoved (Evergreen.V31.Vector2d.Vector2d Pixels.Pixels ScreenCoordinates)
    | MouseDown
    | MouseUp
    | ArrowKeyChanged ArrowKey ButtonState
    | TouchesChanged TouchContact
    | JoystickTouchChanged TouchContact
    | ShootClicked
    | GotPointerLock
    | LostPointerLock
    | GotColorTexture (Result WebGL.Texture.Error (Evergreen.V31.Scene3d.Material.Texture Color.Color))
    | GotRoughnessTexture (Result WebGL.Texture.Error (Evergreen.V31.Scene3d.Material.Texture Float))
    | NoOpFrontendMsg


type ToBackend
    = Join String
    | UpdateMovement (Evergreen.V31.Vector2d.Vector2d Quantity.Unitless Evergreen.V31.Physics.Coordinates.WorldCoordinates)
    | NoOpToBackend


type BackendMsg
    = ClientConnected String String
    | ClientDisconnected String String
    | BackendTick Time.Posix
    | NoOpBackendMsg


type ToFrontend
    = AssignId Int
    | UpdateEntities
        (List
            { id : Int
            , frame :
                Evergreen.V31.Frame3d.Frame3d
                    Length.Meters
                    Evergreen.V31.Physics.Coordinates.WorldCoordinates
                    { defines : Evergreen.V31.Physics.Coordinates.BodyCoordinates
                    }
            , velocity : Evergreen.V31.Vector3d.Vector3d Speed.MetersPerSecond Evergreen.V31.Physics.Coordinates.WorldCoordinates
            , angularVelocity : Evergreen.V31.Vector3d.Vector3d AngularSpeed.RadiansPerSecond Evergreen.V31.Physics.Coordinates.WorldCoordinates
            , movement : Evergreen.V31.Vector2d.Vector2d Quantity.Unitless Evergreen.V31.Physics.Coordinates.WorldCoordinates
            }
        )
    | NoOpToFrontend

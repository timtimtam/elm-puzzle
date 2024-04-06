module Types exposing (..)

import Angle
import AngularSpeed
import Axis3d
import Color
import Direction3d
import Duration
import Frame3d
import Internal.Transform3d
import Lamdera
import Length
import Physics.Coordinates
import Physics.World
import Pixels
import Point2d
import Point3d
import Quantity
import Scene3d.Material
import Set exposing (Set)
import Speed
import Time
import Torque
import Vector2d
import Vector3d
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


type alias FrameRecon =
    { direction : Direction3d.Direction3d Physics.Coordinates.BodyCoordinates
    , angleA : Angle.Angle
    , angleZ : Angle.Angle
    , offset : Vector3d.Vector3d Length.Meters Physics.Coordinates.WorldCoordinates
    }


type WorldData
    = Static
    | Player
        { id : Int
        , torque : Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates
        , recon : FrameRecon
        , localTime : Time.Posix
        }


type BackendWorldData
    = BackendStatic
    | BackendPlayer
        { id : Int
        , torque : Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates
        , localTime : Time.Posix
        , sessionId : Lamdera.SessionId
        , clients : Set Lamdera.ClientId
        }


type FrontendModel
    = Lobby
        { name : String
        , width : Quantity.Quantity Int Pixels.Pixels
        , height : Quantity.Quantity Int Pixels.Pixels
        , playerColorTexture : Maybe (Scene3d.Material.Texture Color.Color)
        , playerRoughnessTexture : Maybe (Scene3d.Material.Texture Float)
        }
    | Joined
        { id : Int
        , name : String
        , width : Quantity.Quantity Int Pixels.Pixels
        , height : Quantity.Quantity Int Pixels.Pixels
        , playerColorTexture : Maybe (Scene3d.Material.Texture Color.Color)
        , playerRoughnessTexture : Maybe (Scene3d.Material.Texture Float)
        , cameraAngle : Direction3d.Direction3d Physics.Coordinates.WorldCoordinates
        , leftKey : ButtonState
        , rightKey : ButtonState
        , upKey : ButtonState
        , downKey : ButtonState
        , mouseButtonState : ButtonState
        , touches : TouchContact
        , currentTime : Time.Posix
        , world : Physics.World.World WorldData
        , joystickOffset : Vector2d.Vector2d Quantity.Unitless ScreenCoordinates
        , viewPivotDelta : Vector2d.Vector2d Pixels.Pixels ScreenCoordinates
        , lightPosition : Point3d.Point3d Length.Meters Physics.Coordinates.WorldCoordinates
        , lastContact : ContactType
        , pointerCapture : PointerCapture
        , historicalMovements : List { movement : Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates, time : Time.Posix }
        }


type ContactType
    = Touch
    | Mouse


type alias BackendModel =
    { world : Physics.World.World BackendWorldData
    , previousTick : Maybe { previousTickTime : Time.Posix, previousUpdateTime : Time.Posix }
    , nextId : Int
    }


type ArrowKey
    = UpKey
    | DownKey
    | LeftKey
    | RightKey


type FrontendMsg
    = WindowResized (Quantity.Quantity Int Pixels.Pixels) (Quantity.Quantity Int Pixels.Pixels)
    | Tick Time.Posix
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
    | JoinedAtTime
        Time.Posix
        Int
        { name : String
        , width : Quantity.Quantity Int Pixels.Pixels
        , height : Quantity.Quantity Int Pixels.Pixels
        , playerColorTexture : Maybe (Scene3d.Material.Texture Color.Color)
        , playerRoughnessTexture : Maybe (Scene3d.Material.Texture Float)
        }
    | NoOpFrontendMsg


type ToBackend
    = Join String
    | UpdateMovement (Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates) Time.Posix
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
            , frame : Frame3d.Frame3d Length.Meters Physics.Coordinates.WorldCoordinates { defines : Physics.Coordinates.BodyCoordinates }
            , velocity : Vector3d.Vector3d Speed.MetersPerSecond Physics.Coordinates.WorldCoordinates
            , angularVelocity : Vector3d.Vector3d AngularSpeed.RadiansPerSecond Physics.Coordinates.WorldCoordinates
            , movement : Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates
            , time : Time.Posix
            }
        )
    | NoOpToFrontend

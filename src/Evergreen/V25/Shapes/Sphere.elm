module Evergreen.V25.Shapes.Sphere exposing (..)

import Evergreen.V25.Internal.Matrix3
import Evergreen.V25.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V25.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V25.Internal.Matrix3.Mat3
    }

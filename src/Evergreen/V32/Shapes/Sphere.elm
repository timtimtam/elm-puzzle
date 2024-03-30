module Evergreen.V32.Shapes.Sphere exposing (..)

import Evergreen.V32.Internal.Matrix3
import Evergreen.V32.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V32.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V32.Internal.Matrix3.Mat3
    }

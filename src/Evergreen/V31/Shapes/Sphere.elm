module Evergreen.V31.Shapes.Sphere exposing (..)

import Evergreen.V31.Internal.Matrix3
import Evergreen.V31.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V31.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V31.Internal.Matrix3.Mat3
    }

module Evergreen.V38.Shapes.Sphere exposing (..)

import Evergreen.V38.Internal.Matrix3
import Evergreen.V38.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V38.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V38.Internal.Matrix3.Mat3
    }

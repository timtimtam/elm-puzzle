module Evergreen.V28.Shapes.Sphere exposing (..)

import Evergreen.V28.Internal.Matrix3
import Evergreen.V28.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V28.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V28.Internal.Matrix3.Mat3
    }

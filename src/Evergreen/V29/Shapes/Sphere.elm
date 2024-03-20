module Evergreen.V29.Shapes.Sphere exposing (..)

import Evergreen.V29.Internal.Matrix3
import Evergreen.V29.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V29.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V29.Internal.Matrix3.Mat3
    }

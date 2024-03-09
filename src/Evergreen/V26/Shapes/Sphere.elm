module Evergreen.V26.Shapes.Sphere exposing (..)

import Evergreen.V26.Internal.Matrix3
import Evergreen.V26.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V26.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V26.Internal.Matrix3.Mat3
    }

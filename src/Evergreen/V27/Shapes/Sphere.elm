module Evergreen.V27.Shapes.Sphere exposing (..)

import Evergreen.V27.Internal.Matrix3
import Evergreen.V27.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V27.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V27.Internal.Matrix3.Mat3
    }

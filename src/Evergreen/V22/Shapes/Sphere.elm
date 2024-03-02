module Evergreen.V22.Shapes.Sphere exposing (..)

import Evergreen.V22.Internal.Matrix3
import Evergreen.V22.Internal.Vector3


type alias Sphere =
    { radius : Float
    , position : Evergreen.V22.Internal.Vector3.Vec3
    , volume : Float
    , inertia : Evergreen.V22.Internal.Matrix3.Mat3
    }

module Evergreen.V31.Shapes.Convex exposing (..)

import Evergreen.V31.Internal.Matrix3
import Evergreen.V31.Internal.Vector3


type alias Face =
    { vertices : List Evergreen.V31.Internal.Vector3.Vec3
    , normal : Evergreen.V31.Internal.Vector3.Vec3
    }


type alias Convex =
    { faces : List Face
    , vertices : List Evergreen.V31.Internal.Vector3.Vec3
    , uniqueEdges : List Evergreen.V31.Internal.Vector3.Vec3
    , uniqueNormals : List Evergreen.V31.Internal.Vector3.Vec3
    , position : Evergreen.V31.Internal.Vector3.Vec3
    , inertia : Evergreen.V31.Internal.Matrix3.Mat3
    , volume : Float
    }

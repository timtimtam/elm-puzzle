module Evergreen.V28.Shapes.Convex exposing (..)

import Evergreen.V28.Internal.Matrix3
import Evergreen.V28.Internal.Vector3


type alias Face =
    { vertices : List Evergreen.V28.Internal.Vector3.Vec3
    , normal : Evergreen.V28.Internal.Vector3.Vec3
    }


type alias Convex =
    { faces : List Face
    , vertices : List Evergreen.V28.Internal.Vector3.Vec3
    , uniqueEdges : List Evergreen.V28.Internal.Vector3.Vec3
    , uniqueNormals : List Evergreen.V28.Internal.Vector3.Vec3
    , position : Evergreen.V28.Internal.Vector3.Vec3
    , inertia : Evergreen.V28.Internal.Matrix3.Mat3
    , volume : Float
    }

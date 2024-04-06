module Evergreen.V38.Shapes.Convex exposing (..)

import Evergreen.V38.Internal.Matrix3
import Evergreen.V38.Internal.Vector3


type alias Face =
    { vertices : List Evergreen.V38.Internal.Vector3.Vec3
    , normal : Evergreen.V38.Internal.Vector3.Vec3
    }


type alias Convex =
    { faces : List Face
    , vertices : List Evergreen.V38.Internal.Vector3.Vec3
    , uniqueEdges : List Evergreen.V38.Internal.Vector3.Vec3
    , uniqueNormals : List Evergreen.V38.Internal.Vector3.Vec3
    , position : Evergreen.V38.Internal.Vector3.Vec3
    , inertia : Evergreen.V38.Internal.Matrix3.Mat3
    , volume : Float
    }

module Evergreen.V22.Shapes.Convex exposing (..)

import Evergreen.V22.Internal.Matrix3
import Evergreen.V22.Internal.Vector3


type alias Face =
    { vertices : List Evergreen.V22.Internal.Vector3.Vec3
    , normal : Evergreen.V22.Internal.Vector3.Vec3
    }


type alias Convex =
    { faces : List Face
    , vertices : List Evergreen.V22.Internal.Vector3.Vec3
    , uniqueEdges : List Evergreen.V22.Internal.Vector3.Vec3
    , uniqueNormals : List Evergreen.V22.Internal.Vector3.Vec3
    , position : Evergreen.V22.Internal.Vector3.Vec3
    , inertia : Evergreen.V22.Internal.Matrix3.Mat3
    , volume : Float
    }

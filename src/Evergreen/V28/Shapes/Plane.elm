module Evergreen.V28.Shapes.Plane exposing (..)

import Evergreen.V28.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V28.Internal.Vector3.Vec3
    , position : Evergreen.V28.Internal.Vector3.Vec3
    }

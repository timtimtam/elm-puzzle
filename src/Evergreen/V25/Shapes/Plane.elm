module Evergreen.V25.Shapes.Plane exposing (..)

import Evergreen.V25.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V25.Internal.Vector3.Vec3
    , position : Evergreen.V25.Internal.Vector3.Vec3
    }

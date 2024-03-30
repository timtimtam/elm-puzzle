module Evergreen.V32.Shapes.Plane exposing (..)

import Evergreen.V32.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V32.Internal.Vector3.Vec3
    , position : Evergreen.V32.Internal.Vector3.Vec3
    }

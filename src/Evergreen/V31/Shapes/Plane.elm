module Evergreen.V31.Shapes.Plane exposing (..)

import Evergreen.V31.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V31.Internal.Vector3.Vec3
    , position : Evergreen.V31.Internal.Vector3.Vec3
    }

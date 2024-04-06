module Evergreen.V38.Shapes.Plane exposing (..)

import Evergreen.V38.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V38.Internal.Vector3.Vec3
    , position : Evergreen.V38.Internal.Vector3.Vec3
    }

module Evergreen.V26.Shapes.Plane exposing (..)

import Evergreen.V26.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V26.Internal.Vector3.Vec3
    , position : Evergreen.V26.Internal.Vector3.Vec3
    }

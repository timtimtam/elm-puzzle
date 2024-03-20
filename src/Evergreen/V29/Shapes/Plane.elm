module Evergreen.V29.Shapes.Plane exposing (..)

import Evergreen.V29.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V29.Internal.Vector3.Vec3
    , position : Evergreen.V29.Internal.Vector3.Vec3
    }

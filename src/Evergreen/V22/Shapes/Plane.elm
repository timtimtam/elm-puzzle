module Evergreen.V22.Shapes.Plane exposing (..)

import Evergreen.V22.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V22.Internal.Vector3.Vec3
    , position : Evergreen.V22.Internal.Vector3.Vec3
    }

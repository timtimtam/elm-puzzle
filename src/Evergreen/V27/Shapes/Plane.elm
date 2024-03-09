module Evergreen.V27.Shapes.Plane exposing (..)

import Evergreen.V27.Internal.Vector3


type alias Plane =
    { normal : Evergreen.V27.Internal.Vector3.Vec3
    , position : Evergreen.V27.Internal.Vector3.Vec3
    }

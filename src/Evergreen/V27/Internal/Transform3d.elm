module Evergreen.V27.Internal.Transform3d exposing (..)

import Evergreen.V27.Internal.Vector3


type Orientation3d
    = Orientation3d Float Float Float Float


type Transform3d coordinates defines
    = Transform3d Evergreen.V27.Internal.Vector3.Vec3 Orientation3d

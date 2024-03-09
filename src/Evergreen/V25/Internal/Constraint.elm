module Evergreen.V25.Internal.Constraint exposing (..)

import Evergreen.V25.Internal.Shape
import Evergreen.V25.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3
    | Hinge Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3
    | Lock Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3 Evergreen.V25.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V25.Internal.Shape.CenterOfMassCoordinates)
    }

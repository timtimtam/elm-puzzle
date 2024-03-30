module Evergreen.V32.Internal.Constraint exposing (..)

import Evergreen.V32.Internal.Shape
import Evergreen.V32.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3
    | Hinge Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3
    | Lock Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3 Evergreen.V32.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V32.Internal.Shape.CenterOfMassCoordinates)
    }

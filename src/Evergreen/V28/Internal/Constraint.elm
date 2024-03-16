module Evergreen.V28.Internal.Constraint exposing (..)

import Evergreen.V28.Internal.Shape
import Evergreen.V28.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3
    | Hinge Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3
    | Lock Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3 Evergreen.V28.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V28.Internal.Shape.CenterOfMassCoordinates)
    }

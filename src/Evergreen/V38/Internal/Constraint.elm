module Evergreen.V38.Internal.Constraint exposing (..)

import Evergreen.V38.Internal.Shape
import Evergreen.V38.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3
    | Hinge Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3
    | Lock Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3 Evergreen.V38.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V38.Internal.Shape.CenterOfMassCoordinates)
    }

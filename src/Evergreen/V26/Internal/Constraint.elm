module Evergreen.V26.Internal.Constraint exposing (..)

import Evergreen.V26.Internal.Shape
import Evergreen.V26.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3
    | Hinge Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3
    | Lock Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3 Evergreen.V26.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V26.Internal.Shape.CenterOfMassCoordinates)
    }

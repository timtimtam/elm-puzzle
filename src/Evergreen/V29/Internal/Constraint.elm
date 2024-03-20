module Evergreen.V29.Internal.Constraint exposing (..)

import Evergreen.V29.Internal.Shape
import Evergreen.V29.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3
    | Hinge Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3
    | Lock Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3 Evergreen.V29.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V29.Internal.Shape.CenterOfMassCoordinates)
    }

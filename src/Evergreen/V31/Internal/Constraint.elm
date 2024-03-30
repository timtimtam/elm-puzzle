module Evergreen.V31.Internal.Constraint exposing (..)

import Evergreen.V31.Internal.Shape
import Evergreen.V31.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3
    | Hinge Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3
    | Lock Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3 Evergreen.V31.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V31.Internal.Shape.CenterOfMassCoordinates)
    }

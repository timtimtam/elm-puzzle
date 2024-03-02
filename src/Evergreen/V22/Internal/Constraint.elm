module Evergreen.V22.Internal.Constraint exposing (..)

import Evergreen.V22.Internal.Shape
import Evergreen.V22.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3
    | Hinge Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3
    | Lock Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3 Evergreen.V22.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V22.Internal.Shape.CenterOfMassCoordinates)
    }

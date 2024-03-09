module Evergreen.V27.Internal.Constraint exposing (..)

import Evergreen.V27.Internal.Shape
import Evergreen.V27.Internal.Vector3


type Constraint coordinates
    = PointToPoint Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3
    | Hinge Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3
    | Lock Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3 Evergreen.V27.Internal.Vector3.Vec3
    | Distance Float


type alias ConstraintGroup =
    { bodyId1 : Int
    , bodyId2 : Int
    , constraints : List (Constraint Evergreen.V27.Internal.Shape.CenterOfMassCoordinates)
    }

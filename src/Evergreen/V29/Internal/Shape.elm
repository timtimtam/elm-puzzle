module Evergreen.V29.Internal.Shape exposing (..)

import Evergreen.V29.Internal.Vector3
import Evergreen.V29.Shapes.Convex
import Evergreen.V29.Shapes.Plane
import Evergreen.V29.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V29.Shapes.Convex.Convex
    | Plane Evergreen.V29.Shapes.Plane.Plane
    | Sphere Evergreen.V29.Shapes.Sphere.Sphere
    | Particle Evergreen.V29.Internal.Vector3.Vec3

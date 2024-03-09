module Evergreen.V26.Internal.Shape exposing (..)

import Evergreen.V26.Internal.Vector3
import Evergreen.V26.Shapes.Convex
import Evergreen.V26.Shapes.Plane
import Evergreen.V26.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V26.Shapes.Convex.Convex
    | Plane Evergreen.V26.Shapes.Plane.Plane
    | Sphere Evergreen.V26.Shapes.Sphere.Sphere
    | Particle Evergreen.V26.Internal.Vector3.Vec3

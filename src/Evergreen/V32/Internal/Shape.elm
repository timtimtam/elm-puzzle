module Evergreen.V32.Internal.Shape exposing (..)

import Evergreen.V32.Internal.Vector3
import Evergreen.V32.Shapes.Convex
import Evergreen.V32.Shapes.Plane
import Evergreen.V32.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V32.Shapes.Convex.Convex
    | Plane Evergreen.V32.Shapes.Plane.Plane
    | Sphere Evergreen.V32.Shapes.Sphere.Sphere
    | Particle Evergreen.V32.Internal.Vector3.Vec3

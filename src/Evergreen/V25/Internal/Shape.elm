module Evergreen.V25.Internal.Shape exposing (..)

import Evergreen.V25.Internal.Vector3
import Evergreen.V25.Shapes.Convex
import Evergreen.V25.Shapes.Plane
import Evergreen.V25.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V25.Shapes.Convex.Convex
    | Plane Evergreen.V25.Shapes.Plane.Plane
    | Sphere Evergreen.V25.Shapes.Sphere.Sphere
    | Particle Evergreen.V25.Internal.Vector3.Vec3

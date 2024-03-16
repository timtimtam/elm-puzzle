module Evergreen.V28.Internal.Shape exposing (..)

import Evergreen.V28.Internal.Vector3
import Evergreen.V28.Shapes.Convex
import Evergreen.V28.Shapes.Plane
import Evergreen.V28.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V28.Shapes.Convex.Convex
    | Plane Evergreen.V28.Shapes.Plane.Plane
    | Sphere Evergreen.V28.Shapes.Sphere.Sphere
    | Particle Evergreen.V28.Internal.Vector3.Vec3

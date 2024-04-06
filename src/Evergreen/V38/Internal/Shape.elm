module Evergreen.V38.Internal.Shape exposing (..)

import Evergreen.V38.Internal.Vector3
import Evergreen.V38.Shapes.Convex
import Evergreen.V38.Shapes.Plane
import Evergreen.V38.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V38.Shapes.Convex.Convex
    | Plane Evergreen.V38.Shapes.Plane.Plane
    | Sphere Evergreen.V38.Shapes.Sphere.Sphere
    | Particle Evergreen.V38.Internal.Vector3.Vec3

module Evergreen.V31.Internal.Shape exposing (..)

import Evergreen.V31.Internal.Vector3
import Evergreen.V31.Shapes.Convex
import Evergreen.V31.Shapes.Plane
import Evergreen.V31.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V31.Shapes.Convex.Convex
    | Plane Evergreen.V31.Shapes.Plane.Plane
    | Sphere Evergreen.V31.Shapes.Sphere.Sphere
    | Particle Evergreen.V31.Internal.Vector3.Vec3

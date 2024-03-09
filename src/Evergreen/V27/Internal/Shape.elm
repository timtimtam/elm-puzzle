module Evergreen.V27.Internal.Shape exposing (..)

import Evergreen.V27.Internal.Vector3
import Evergreen.V27.Shapes.Convex
import Evergreen.V27.Shapes.Plane
import Evergreen.V27.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V27.Shapes.Convex.Convex
    | Plane Evergreen.V27.Shapes.Plane.Plane
    | Sphere Evergreen.V27.Shapes.Sphere.Sphere
    | Particle Evergreen.V27.Internal.Vector3.Vec3

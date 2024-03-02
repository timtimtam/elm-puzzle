module Evergreen.V22.Internal.Shape exposing (..)

import Evergreen.V22.Internal.Vector3
import Evergreen.V22.Shapes.Convex
import Evergreen.V22.Shapes.Plane
import Evergreen.V22.Shapes.Sphere


type CenterOfMassCoordinates
    = CenterOfMassCoordinates


type Shape coordinates
    = Convex Evergreen.V22.Shapes.Convex.Convex
    | Plane Evergreen.V22.Shapes.Plane.Plane
    | Sphere Evergreen.V22.Shapes.Sphere.Sphere
    | Particle Evergreen.V22.Internal.Vector3.Vec3

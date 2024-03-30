module Evergreen.V32.Internal.Body exposing (..)

import Evergreen.V32.Internal.Material
import Evergreen.V32.Internal.Matrix3
import Evergreen.V32.Internal.Shape
import Evergreen.V32.Internal.Transform3d
import Evergreen.V32.Internal.Vector3
import Evergreen.V32.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V32.Internal.Material.Material
    , transform3d :
        Evergreen.V32.Internal.Transform3d.Transform3d
            Evergreen.V32.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V32.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V32.Internal.Transform3d.Transform3d
            Evergreen.V32.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V32.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V32.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V32.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V32.Internal.Shape.Shape Evergreen.V32.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V32.Internal.Shape.Shape Evergreen.V32.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V32.Internal.Vector3.Vec3
    , torque : Evergreen.V32.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V32.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V32.Internal.Matrix3.Mat3
    }

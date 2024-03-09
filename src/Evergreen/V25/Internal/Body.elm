module Evergreen.V25.Internal.Body exposing (..)

import Evergreen.V25.Internal.Material
import Evergreen.V25.Internal.Matrix3
import Evergreen.V25.Internal.Shape
import Evergreen.V25.Internal.Transform3d
import Evergreen.V25.Internal.Vector3
import Evergreen.V25.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V25.Internal.Material.Material
    , transform3d :
        Evergreen.V25.Internal.Transform3d.Transform3d
            Evergreen.V25.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V25.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V25.Internal.Transform3d.Transform3d
            Evergreen.V25.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V25.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V25.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V25.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V25.Internal.Shape.Shape Evergreen.V25.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V25.Internal.Shape.Shape Evergreen.V25.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V25.Internal.Vector3.Vec3
    , torque : Evergreen.V25.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V25.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V25.Internal.Matrix3.Mat3
    }

module Evergreen.V22.Internal.Body exposing (..)

import Evergreen.V22.Internal.Material
import Evergreen.V22.Internal.Matrix3
import Evergreen.V22.Internal.Shape
import Evergreen.V22.Internal.Transform3d
import Evergreen.V22.Internal.Vector3
import Evergreen.V22.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V22.Internal.Material.Material
    , transform3d :
        Evergreen.V22.Internal.Transform3d.Transform3d
            Evergreen.V22.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V22.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V22.Internal.Transform3d.Transform3d
            Evergreen.V22.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V22.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V22.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V22.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V22.Internal.Shape.Shape Evergreen.V22.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V22.Internal.Shape.Shape Evergreen.V22.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V22.Internal.Vector3.Vec3
    , torque : Evergreen.V22.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V22.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V22.Internal.Matrix3.Mat3
    }

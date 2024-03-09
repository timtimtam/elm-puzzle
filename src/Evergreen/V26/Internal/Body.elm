module Evergreen.V26.Internal.Body exposing (..)

import Evergreen.V26.Internal.Material
import Evergreen.V26.Internal.Matrix3
import Evergreen.V26.Internal.Shape
import Evergreen.V26.Internal.Transform3d
import Evergreen.V26.Internal.Vector3
import Evergreen.V26.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V26.Internal.Material.Material
    , transform3d :
        Evergreen.V26.Internal.Transform3d.Transform3d
            Evergreen.V26.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V26.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V26.Internal.Transform3d.Transform3d
            Evergreen.V26.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V26.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V26.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V26.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V26.Internal.Shape.Shape Evergreen.V26.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V26.Internal.Shape.Shape Evergreen.V26.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V26.Internal.Vector3.Vec3
    , torque : Evergreen.V26.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V26.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V26.Internal.Matrix3.Mat3
    }

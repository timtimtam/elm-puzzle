module Evergreen.V28.Internal.Body exposing (..)

import Evergreen.V28.Internal.Material
import Evergreen.V28.Internal.Matrix3
import Evergreen.V28.Internal.Shape
import Evergreen.V28.Internal.Transform3d
import Evergreen.V28.Internal.Vector3
import Evergreen.V28.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V28.Internal.Material.Material
    , transform3d :
        Evergreen.V28.Internal.Transform3d.Transform3d
            Evergreen.V28.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V28.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V28.Internal.Transform3d.Transform3d
            Evergreen.V28.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V28.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V28.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V28.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V28.Internal.Shape.Shape Evergreen.V28.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V28.Internal.Shape.Shape Evergreen.V28.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V28.Internal.Vector3.Vec3
    , torque : Evergreen.V28.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V28.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V28.Internal.Matrix3.Mat3
    }

module Evergreen.V38.Internal.Body exposing (..)

import Evergreen.V38.Internal.Material
import Evergreen.V38.Internal.Matrix3
import Evergreen.V38.Internal.Shape
import Evergreen.V38.Internal.Transform3d
import Evergreen.V38.Internal.Vector3
import Evergreen.V38.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V38.Internal.Material.Material
    , transform3d :
        Evergreen.V38.Internal.Transform3d.Transform3d
            Evergreen.V38.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V38.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V38.Internal.Transform3d.Transform3d
            Evergreen.V38.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V38.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V38.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V38.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V38.Internal.Shape.Shape Evergreen.V38.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V38.Internal.Shape.Shape Evergreen.V38.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V38.Internal.Vector3.Vec3
    , torque : Evergreen.V38.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V38.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V38.Internal.Matrix3.Mat3
    }

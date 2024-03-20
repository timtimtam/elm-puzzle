module Evergreen.V29.Internal.Body exposing (..)

import Evergreen.V29.Internal.Material
import Evergreen.V29.Internal.Matrix3
import Evergreen.V29.Internal.Shape
import Evergreen.V29.Internal.Transform3d
import Evergreen.V29.Internal.Vector3
import Evergreen.V29.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V29.Internal.Material.Material
    , transform3d :
        Evergreen.V29.Internal.Transform3d.Transform3d
            Evergreen.V29.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V29.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V29.Internal.Transform3d.Transform3d
            Evergreen.V29.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V29.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V29.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V29.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V29.Internal.Shape.Shape Evergreen.V29.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V29.Internal.Shape.Shape Evergreen.V29.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V29.Internal.Vector3.Vec3
    , torque : Evergreen.V29.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V29.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V29.Internal.Matrix3.Mat3
    }

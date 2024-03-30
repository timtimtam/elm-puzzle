module Evergreen.V31.Internal.Body exposing (..)

import Evergreen.V31.Internal.Material
import Evergreen.V31.Internal.Matrix3
import Evergreen.V31.Internal.Shape
import Evergreen.V31.Internal.Transform3d
import Evergreen.V31.Internal.Vector3
import Evergreen.V31.Physics.Coordinates


type alias Body data =
    { id : Int
    , data : data
    , material : Evergreen.V31.Internal.Material.Material
    , transform3d :
        Evergreen.V31.Internal.Transform3d.Transform3d
            Evergreen.V31.Physics.Coordinates.WorldCoordinates
            { defines : Evergreen.V31.Internal.Shape.CenterOfMassCoordinates
            }
    , centerOfMassTransform3d :
        Evergreen.V31.Internal.Transform3d.Transform3d
            Evergreen.V31.Physics.Coordinates.BodyCoordinates
            { defines : Evergreen.V31.Internal.Shape.CenterOfMassCoordinates
            }
    , velocity : Evergreen.V31.Internal.Vector3.Vec3
    , angularVelocity : Evergreen.V31.Internal.Vector3.Vec3
    , mass : Float
    , shapes : List (Evergreen.V31.Internal.Shape.Shape Evergreen.V31.Internal.Shape.CenterOfMassCoordinates)
    , worldShapes : List (Evergreen.V31.Internal.Shape.Shape Evergreen.V31.Physics.Coordinates.WorldCoordinates)
    , force : Evergreen.V31.Internal.Vector3.Vec3
    , torque : Evergreen.V31.Internal.Vector3.Vec3
    , boundingSphereRadius : Float
    , linearDamping : Float
    , angularDamping : Float
    , invMass : Float
    , invInertia : Evergreen.V31.Internal.Matrix3.Mat3
    , invInertiaWorld : Evergreen.V31.Internal.Matrix3.Mat3
    }

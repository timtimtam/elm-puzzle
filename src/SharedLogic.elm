module SharedLogic exposing (..)

import Angle
import Constants
import Direction2d
import Direction3d
import Duration
import Frame3d
import Lamdera
import Length
import Physics.Body
import Physics.Coordinates
import Physics.World
import Point3d
import Quantity
import Set exposing (Set)
import SketchPlane3d
import Torque
import Types exposing (..)
import Vector2d
import Vector3d


applyTorque : Vector3d.Vector3d Torque.NewtonMeters Physics.Coordinates.WorldCoordinates -> Physics.Body.Body data -> Physics.Body.Body data
applyTorque torque body =
    case Vector3d.direction torque of
        Just torqueDirection ->
            let
                centerOfMass =
                    Physics.Body.centerOfMass body |> Point3d.placeIn (Physics.Body.frame body)

                offsetLength =
                    Length.inches 0.1

                frame =
                    Frame3d.withZDirection torqueDirection centerOfMass

                offsetVector =
                    Frame3d.yDirection frame |> Vector3d.withLength offsetLength

                newtons =
                    Vector3d.length torque
                        |> Quantity.over_ offsetLength
                        |> Quantity.half
            in
            body
                |> Physics.Body.applyForce
                    newtons
                    (Frame3d.xDirection frame)
                    (centerOfMass |> Point3d.translateBy offsetVector)
                |> Physics.Body.applyForce
                    newtons
                    (Frame3d.xDirection frame |> Direction3d.reverse)
                    (centerOfMass |> Point3d.translateBy (Vector3d.reverse offsetVector))

        Nothing ->
            body


applyMovementForce : Vector2d.Vector2d Quantity.Unitless coordinates -> Physics.Body.Body data -> Physics.Body.Body data
applyMovementForce movement body =
    let
        joystickCapped =
            if Vector2d.length movement |> Quantity.greaterThan (Quantity.float 1) then
                Vector2d.normalize movement

            else
                movement

        torqueMagnitude =
            Constants.maxTorque |> Quantity.timesUnitless (Vector2d.length joystickCapped)

        torqueDirection =
            case Vector2d.direction joystickCapped of
                Just direction2d ->
                    Direction3d.on SketchPlane3d.xy
                        (direction2d |> Direction2d.rotateBy (Angle.turns -0.25))

                Nothing ->
                    Direction3d.z
    in
    body |> applyTorque (torqueDirection |> Vector3d.withLength torqueMagnitude)

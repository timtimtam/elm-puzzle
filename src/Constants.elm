module Constants exposing (..)

import Acceleration
import Angle
import Duration
import Pixels
import Quantity
import Torque


gravity : Acceleration.Acceleration
gravity =
    Acceleration.metersPerSecondSquared 9.80665


dampingLinear : Float
dampingLinear =
    0.3


dampingAngular : Float
dampingAngular =
    0.2


maxTorque : Torque.Torque
maxTorque =
    Torque.newtonMeters 0.05


friction : Float
friction =
    0.002


bounciness : Float
bounciness =
    0.5


radiansPerPixel : Quantity.Quantity Float (Quantity.Rate Angle.Radians Pixels.Pixels)
radiansPerPixel =
    Angle.radians -0.004 |> Quantity.per (Pixels.float 1)


reconRate : Quantity.Quantity Float (Quantity.Rate Quantity.Unitless Duration.Seconds)
reconRate =
    Quantity.float 0.99 |> Quantity.per Duration.second


joystickSize : Quantity.Quantity Float Pixels.Pixels
joystickSize =
    Pixels.float 20


pixelsPerJoystickWidth : Quantity.Quantity Float (Quantity.Rate Pixels.Pixels Quantity.Unitless)
pixelsPerJoystickWidth =
    Pixels.float 40 |> Quantity.per (Quantity.float 1)

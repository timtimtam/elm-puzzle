module Constants exposing (..)

import Acceleration
import Angle
import Duration
import Pixels
import Quantity
import Torque


gravity =
    Acceleration.metersPerSecondSquared 9.80665


dampingLinear =
    0.3


dampingAngular =
    0.2


maxTorque =
    Torque.newtonMeters 0.05


friction =
    0.002


bounciness =
    0.5


radiansPerPixel =
    Angle.radians -0.004 |> Quantity.per (Pixels.float 1)


reconRate =
    Quantity.float 0.99 |> Quantity.per Duration.second

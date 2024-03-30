module Constants exposing (..)

import Acceleration
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

module Evergreen.V25.Internal.Contact exposing (..)

import Evergreen.V25.Internal.Body
import Evergreen.V25.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V25.Internal.Vector3.Vec3
    , pi : Evergreen.V25.Internal.Vector3.Vec3
    , pj : Evergreen.V25.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V25.Internal.Body.Body data
    , body2 : Evergreen.V25.Internal.Body.Body data
    , contacts : List Contact
    }

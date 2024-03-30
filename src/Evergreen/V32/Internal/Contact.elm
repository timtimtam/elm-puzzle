module Evergreen.V32.Internal.Contact exposing (..)

import Evergreen.V32.Internal.Body
import Evergreen.V32.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V32.Internal.Vector3.Vec3
    , pi : Evergreen.V32.Internal.Vector3.Vec3
    , pj : Evergreen.V32.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V32.Internal.Body.Body data
    , body2 : Evergreen.V32.Internal.Body.Body data
    , contacts : List Contact
    }

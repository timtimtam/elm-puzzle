module Evergreen.V31.Internal.Contact exposing (..)

import Evergreen.V31.Internal.Body
import Evergreen.V31.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V31.Internal.Vector3.Vec3
    , pi : Evergreen.V31.Internal.Vector3.Vec3
    , pj : Evergreen.V31.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V31.Internal.Body.Body data
    , body2 : Evergreen.V31.Internal.Body.Body data
    , contacts : List Contact
    }

module Evergreen.V26.Internal.Contact exposing (..)

import Evergreen.V26.Internal.Body
import Evergreen.V26.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V26.Internal.Vector3.Vec3
    , pi : Evergreen.V26.Internal.Vector3.Vec3
    , pj : Evergreen.V26.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V26.Internal.Body.Body data
    , body2 : Evergreen.V26.Internal.Body.Body data
    , contacts : List Contact
    }

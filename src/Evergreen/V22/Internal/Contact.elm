module Evergreen.V22.Internal.Contact exposing (..)

import Evergreen.V22.Internal.Body
import Evergreen.V22.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V22.Internal.Vector3.Vec3
    , pi : Evergreen.V22.Internal.Vector3.Vec3
    , pj : Evergreen.V22.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V22.Internal.Body.Body data
    , body2 : Evergreen.V22.Internal.Body.Body data
    , contacts : List Contact
    }

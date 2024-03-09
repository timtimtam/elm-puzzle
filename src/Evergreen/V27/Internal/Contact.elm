module Evergreen.V27.Internal.Contact exposing (..)

import Evergreen.V27.Internal.Body
import Evergreen.V27.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V27.Internal.Vector3.Vec3
    , pi : Evergreen.V27.Internal.Vector3.Vec3
    , pj : Evergreen.V27.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V27.Internal.Body.Body data
    , body2 : Evergreen.V27.Internal.Body.Body data
    , contacts : List Contact
    }

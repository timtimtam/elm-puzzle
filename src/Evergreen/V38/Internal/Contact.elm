module Evergreen.V38.Internal.Contact exposing (..)

import Evergreen.V38.Internal.Body
import Evergreen.V38.Internal.Vector3


type alias Contact =
    { ni : Evergreen.V38.Internal.Vector3.Vec3
    , pi : Evergreen.V38.Internal.Vector3.Vec3
    , pj : Evergreen.V38.Internal.Vector3.Vec3
    }


type alias ContactGroup data =
    { body1 : Evergreen.V38.Internal.Body.Body data
    , body2 : Evergreen.V38.Internal.Body.Body data
    , contacts : List Contact
    }

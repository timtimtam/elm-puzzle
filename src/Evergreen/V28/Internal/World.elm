module Evergreen.V28.Internal.World exposing (..)

import Array
import Evergreen.V28.Internal.Body
import Evergreen.V28.Internal.Constraint
import Evergreen.V28.Internal.Contact
import Evergreen.V28.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V28.Internal.Body.Body data)
    , constraints : List Evergreen.V28.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V28.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V28.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V28.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

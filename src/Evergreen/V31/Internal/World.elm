module Evergreen.V31.Internal.World exposing (..)

import Array
import Evergreen.V31.Internal.Body
import Evergreen.V31.Internal.Constraint
import Evergreen.V31.Internal.Contact
import Evergreen.V31.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V31.Internal.Body.Body data)
    , constraints : List Evergreen.V31.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V31.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V31.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V31.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

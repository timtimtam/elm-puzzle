module Evergreen.V38.Internal.World exposing (..)

import Array
import Evergreen.V38.Internal.Body
import Evergreen.V38.Internal.Constraint
import Evergreen.V38.Internal.Contact
import Evergreen.V38.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V38.Internal.Body.Body data)
    , constraints : List Evergreen.V38.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V38.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V38.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V38.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

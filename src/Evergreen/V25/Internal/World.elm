module Evergreen.V25.Internal.World exposing (..)

import Array
import Evergreen.V25.Internal.Body
import Evergreen.V25.Internal.Constraint
import Evergreen.V25.Internal.Contact
import Evergreen.V25.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V25.Internal.Body.Body data)
    , constraints : List Evergreen.V25.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V25.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V25.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V25.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

module Evergreen.V26.Internal.World exposing (..)

import Array
import Evergreen.V26.Internal.Body
import Evergreen.V26.Internal.Constraint
import Evergreen.V26.Internal.Contact
import Evergreen.V26.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V26.Internal.Body.Body data)
    , constraints : List Evergreen.V26.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V26.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V26.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V26.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

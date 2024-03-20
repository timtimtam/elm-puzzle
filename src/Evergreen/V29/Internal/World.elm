module Evergreen.V29.Internal.World exposing (..)

import Array
import Evergreen.V29.Internal.Body
import Evergreen.V29.Internal.Constraint
import Evergreen.V29.Internal.Contact
import Evergreen.V29.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V29.Internal.Body.Body data)
    , constraints : List Evergreen.V29.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V29.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V29.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V29.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

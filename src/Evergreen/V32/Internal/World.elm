module Evergreen.V32.Internal.World exposing (..)

import Array
import Evergreen.V32.Internal.Body
import Evergreen.V32.Internal.Constraint
import Evergreen.V32.Internal.Contact
import Evergreen.V32.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V32.Internal.Body.Body data)
    , constraints : List Evergreen.V32.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V32.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V32.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V32.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

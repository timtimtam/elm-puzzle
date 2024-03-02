module Evergreen.V22.Internal.World exposing (..)

import Array
import Evergreen.V22.Internal.Body
import Evergreen.V22.Internal.Constraint
import Evergreen.V22.Internal.Contact
import Evergreen.V22.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V22.Internal.Body.Body data)
    , constraints : List Evergreen.V22.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V22.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V22.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V22.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

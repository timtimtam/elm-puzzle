module Evergreen.V27.Internal.World exposing (..)

import Array
import Evergreen.V27.Internal.Body
import Evergreen.V27.Internal.Constraint
import Evergreen.V27.Internal.Contact
import Evergreen.V27.Internal.Vector3


type alias World data =
    { bodies : List (Evergreen.V27.Internal.Body.Body data)
    , constraints : List Evergreen.V27.Internal.Constraint.ConstraintGroup
    , freeIds : List Int
    , nextBodyId : Int
    , gravity : Evergreen.V27.Internal.Vector3.Vec3
    , contactGroups : List (Evergreen.V27.Internal.Contact.ContactGroup data)
    , simulatedBodies : Array.Array (Evergreen.V27.Internal.Body.Body data)
    }


type Protected data
    = Protected (World data)

module Evergreen.V29.Geometry.Types exposing (..)


type Direction3d coordinates
    = Direction3d
        { x : Float
        , y : Float
        , z : Float
        }


type Point2d units coordinates
    = Point2d
        { x : Float
        , y : Float
        }


type Vector2d units coordinates
    = Vector2d
        { x : Float
        , y : Float
        }


type Point3d units coordinates
    = Point3d
        { x : Float
        , y : Float
        , z : Float
        }

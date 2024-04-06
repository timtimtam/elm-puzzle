module Evergreen.V38.Geometry.Types exposing (..)


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


type Vector3d units coordinates
    = Vector3d
        { x : Float
        , y : Float
        , z : Float
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


type Frame3d units coordinates defines
    = Frame3d
        { originPoint : Point3d units coordinates
        , xDirection : Direction3d coordinates
        , yDirection : Direction3d coordinates
        , zDirection : Direction3d coordinates
        }

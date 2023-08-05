module Direction3dWire exposing (Direction3dWire, fromDirection3d, toDirection3d)

import Direction3d exposing (Direction3d)


type Direction3dWire coordinates
    = Direction3dWire Float Float Float


fromDirection3d : Direction3d a -> Direction3dWire a
fromDirection3d direction3d =
    let
        { x, y, z } =
            Direction3d.unwrap direction3d
    in
    Direction3dWire x y z


toDirection3d : Direction3dWire a -> Direction3d a
toDirection3d (Direction3dWire x y z) =
    Direction3d.unsafe { x = x, y = y, z = z }

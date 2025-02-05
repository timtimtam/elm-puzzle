module Evergreen.V31.Scene3d.Types exposing (..)

import WebGL.Texture


type Texture value
    = Constant value
    | Texture
        { url : String
        , options : WebGL.Texture.Options
        , data : WebGL.Texture.Texture
        }

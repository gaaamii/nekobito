module LocalStorageValue exposing (LocalStorageValue, decode, encode)

import ColorTheme exposing (ColorTheme)
import Json.Decode as Decode
import Json.Encode as Encode
import LayoutMode exposing (LayoutMode)


type alias LocalStorageValue =
    { colorTheme : ColorTheme
    , layoutMode : LayoutMode
    }


encode : LocalStorageValue -> Encode.Value
encode value =
    Encode.object
        [ ( "colorTheme", ColorTheme.encode value.colorTheme )
        , ( "layoutMode", LayoutMode.encode value.layoutMode )
        ]


decode : Decode.Value -> Result Decode.Error LocalStorageValue
decode value =
    let
        decoder =
            Decode.map2 LocalStorageValue
                (Decode.field "colorTheme" ColorTheme.decode)
                (Decode.field "layoutMode" LayoutMode.decode)
    in
    Decode.decodeValue decoder value

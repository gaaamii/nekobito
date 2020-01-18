module ColorTheme exposing (ColorTheme(..), decode, encode)

import Json.Decode as Decode
import Json.Encode as Encode


type ColorTheme
    = White
    | Dark


encode : ColorTheme -> Encode.Value
encode colorTheme =
    case colorTheme of
        Dark ->
            Encode.string "DarkTheme"

        White ->
            Encode.string "WhiteTheme"


decode =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "DarkTheme" ->
                        Decode.succeed Dark

                    _ ->
                        Decode.succeed White
            )

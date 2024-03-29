module Models.ColorTheme exposing (ColorTheme(..), decode, encode, toClassName, toggle)

import Json.Decode as Decode
import Json.Encode as Encode


type ColorTheme
    = White
    | Dark


toggle : ColorTheme -> ColorTheme
toggle colorTheme =
    case colorTheme of
        Dark ->
            White

        White ->
            Dark


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


toClassName : ColorTheme -> String
toClassName colorTheme =
    case colorTheme of
        White ->
            "app-wrapper--white-theme"

        Dark ->
            "app-wrapper--dark-theme"

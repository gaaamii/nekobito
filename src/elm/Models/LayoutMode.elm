module Models.LayoutMode exposing (LayoutMode(..), decode, encode, toString, toggle, togglePreview)

import Json.Decode as Decode
import Json.Encode as Encode


type LayoutMode
    = Write
    | Focus
    | Read


decode : Decode.Decoder LayoutMode
decode =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Write" ->
                        Decode.succeed Write

                    "Focus" ->
                        Decode.succeed Focus

                    "Read" ->
                        Decode.succeed Read

                    _ ->
                        Decode.succeed Write
            )


encode : LayoutMode -> Encode.Value
encode layoutMode =
    layoutMode |> toString |> Encode.string


toString : LayoutMode -> String
toString layoutMode =
    case layoutMode of
        Write ->
            "Write"

        Focus ->
            "Focus"

        Read ->
            "Read"


togglePreview : LayoutMode -> LayoutMode
togglePreview currentMode =
    case currentMode of
        Focus ->
            Read

        Read ->
            Focus

        _ ->
            currentMode


toggle : LayoutMode -> LayoutMode
toggle currentMode =
    case currentMode of
        Focus ->
            Write

        Read ->
            Write

        Write ->
            Focus

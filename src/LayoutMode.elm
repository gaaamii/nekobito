module LayoutMode exposing (LayoutMode(..), decode, encode, toString, toggleMainColumns, transitToComparableMode, transitToEditableMode, transitToPreviewMode)

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


toggleMainColumns : LayoutMode -> LayoutMode
toggleMainColumns currentMode =
    case currentMode of
        Focus ->
            Write

        Read ->
            Write

        Write ->
            Focus


transitToEditableMode : LayoutMode -> LayoutMode
transitToEditableMode currentMode =
    case currentMode of
        Read ->
            Focus

        _ ->
            Write


transitToPreviewMode : LayoutMode -> LayoutMode
transitToPreviewMode currentMode =
    case currentMode of
        Focus ->
            Read

        Read ->
            Focus

        _ ->
            Write


transitToComparableMode : LayoutMode -> LayoutMode
transitToComparableMode currentMode =
    case currentMode of
        Focus ->
            Write

        Read ->
            Write

        _ ->
            Write

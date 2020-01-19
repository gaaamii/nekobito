module LayoutMode exposing (LayoutMode(..), decode, encode, next, toString, transitToEditableMode, transitToPreviewMode)

import Json.Decode as Decode
import Json.Encode as Encode


type LayoutMode
    = Write
    | Focus
    | Read
    | Modify
    | Preview


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

                    "Modify" ->
                        Decode.succeed Modify

                    "Preview" ->
                        Decode.succeed Preview

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

        Modify ->
            "Modify"

        Preview ->
            "Preview"


next : LayoutMode -> LayoutMode
next currentMode =
    case currentMode of
        Write ->
            Preview

        _ ->
            Write


transitToEditableMode : LayoutMode -> LayoutMode
transitToEditableMode currentMode =
    case currentMode of
        Read ->
            Focus

        Preview ->
            Modify

        _ ->
            Write


transitToPreviewMode : LayoutMode -> LayoutMode
transitToPreviewMode currentMode =
    case currentMode of
        Focus ->
            Read

        Modify ->
            Preview

        _ ->
            Write

module LayoutMode exposing (LayoutMode(..), decode, encode, toString, toggleList, toggleMainColumns, transitToComparableMode, transitToEditableMode, transitToPreviewMode)

import Json.Decode as Decode
import Json.Encode as Encode


type LayoutMode
    = Write
    | Focus
    | Read
    | Modify
    | Preview
    | OpenAll


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

                    "Modify" ->
                        Decode.succeed Modify

                    "Preview" ->
                        Decode.succeed Preview

                    "OpenAll" ->
                        Decode.succeed OpenAll

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

        OpenAll ->
            "OpenAll"


toggleList : LayoutMode -> LayoutMode
toggleList currentMode =
    case currentMode of
        -- Open list
        Write ->
            OpenAll

        Focus ->
            Modify

        Read ->
            Preview

        -- Close list
        Modify ->
            Focus

        Preview ->
            Read

        OpenAll ->
            Write


toggleMainColumns : LayoutMode -> LayoutMode
toggleMainColumns currentMode =
    case currentMode of
        Focus ->
            Write

        Read ->
            Write

        Modify ->
            OpenAll

        Preview ->
            OpenAll

        Write ->
            Focus

        OpenAll ->
            Modify


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


transitToComparableMode : LayoutMode -> LayoutMode
transitToComparableMode currentMode =
    case currentMode of
        Focus ->
            Write

        Read ->
            Write

        Modify ->
            OpenAll

        Preview ->
            OpenAll

        _ ->
            Write

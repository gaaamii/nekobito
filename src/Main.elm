port module Main exposing (Model, ModelExposedToStorage, Msg(..), appListItemClass, emptyModel, init, main, setStorage, switchColorTheme, update, updateWithStorage, view)

import Browser
import ColorTheme exposing (ColorTheme)
import Html exposing (Html, aside, button, div, i, text, textarea)
import Html.Attributes exposing (class, id, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import LayoutMode exposing (LayoutMode)
import LocalStorageValue
import Markdown
import Note exposing (Note)



---- MODEL ----


type alias Model =
    { colorTheme : ColorTheme
    , note : Note
    , layoutMode : LayoutMode
    }


type alias ModelExposedToStorage =
    { colorTheme : ColorTheme
    , layoutMode : LayoutMode
    }


emptyModel : Model
emptyModel =
    { colorTheme = ColorTheme.White
    , note = Note.new
    , layoutMode = LayoutMode.Write
    }


buildModelFrom : Decode.Value -> Model
buildModelFrom value =
    let
        decoded =
            value |> LocalStorageValue.decode

        maybeValue =
            case decoded of
                Result.Ok v ->
                    Just v

                Result.Err _ ->
                    Nothing

        decodedValue =
            maybeValue
                |> Maybe.withDefault { layoutMode = emptyModel.layoutMode, colorTheme = emptyModel.colorTheme }
    in
    { emptyModel | layoutMode = decodedValue.layoutMode, colorTheme = decodedValue.colorTheme }


init : Decode.Value -> ( Model, Cmd Msg )
init value =
    ( buildModelFrom value, Cmd.none )



---- UPDATE ----


type Msg
    = OnInput String
    | AddNewNote
    | SwitchColorTheme
    | SwitchLayout LayoutMode
    | FileLoaded Decode.Value
    | FileWritten Bool
    | SaveFile
    | OpenFile


switchColorTheme : Model -> Model
switchColorTheme model =
    case model.colorTheme of
        ColorTheme.White ->
            { model | colorTheme = ColorTheme.Dark }

        ColorTheme.Dark ->
            { model | colorTheme = ColorTheme.White }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            let
                note =
                    model.note
            in
            ( { model | note = { note | text = newBody } }
            , Cmd.none
            )

        AddNewNote ->
            ( { model | note = Note.new }, Cmd.none )

        SwitchColorTheme ->
            ( switchColorTheme model, Cmd.none )

        SwitchLayout mode ->
            ( { model | layoutMode = mode }, Cmd.none )

        OpenFile ->
            ( model, Cmd.batch [ openFile () ] )

        FileLoaded value ->
            let
                decoded =
                    Note.decode value

                note =
                    case decoded of
                        Ok loadedNote ->
                            loadedNote

                        Err _ ->
                            Note.new
            in
            ( { model | note = note }, Cmd.none )

        FileWritten _ ->
            ( model, Cmd.none )

        SaveFile ->
            ( model, Cmd.batch [ writeFile model.note.text ] )



---- VIEW ----
-- main view


view : Model -> Html Msg
view model =
    div [ class <| "app-wrapper " ++ themeClass model.colorTheme ]
        [ div [ class <| "app-container " ++ layoutClass model.layoutMode ]
            [ viewSidebar model
            , viewEditor model
            , viewPreview model
            , viewControl model
            ]
        ]



-- sub views


viewSidebar : Model -> Html Msg
viewSidebar model =
    aside [ class "app-sidebar" ]
        [ div [ class "app-sidebar__buttons" ]
            [ button [ class "app-sidebar__buttons__btn btn btn-control-point", onClick AddNewNote ]
                [ i [ class "material-icons" ] [ text "note_add" ] ]
            , button [ class "app-sidebar__buttons__btn btn", onClick SaveFile ]
                [ i [ class "material-icons" ] [ text "save" ] ]
            , button [ id "openFileButton", class "app-sidebar__buttons__btn btn", onClick OpenFile ]
                [ i [ class "material-icons" ] [ text "folder" ] ]
            , button [ class "app-sidebar__buttons__btn btn", onClick SwitchColorTheme ]
                [ i [ class "material-icons" ] [ text "lightbulb_outline" ] ]
            , button [ class "app-sidebar__buttons__btn btn", onClick (SwitchLayout (model.layoutMode |> LayoutMode.toggleMainColumns)) ]
                [ i [ class "material-icons" ] [ text "compare" ] ]
            ]
        ]


viewEditor : Model -> Html Msg
viewEditor model =
    div [ class "app-editor" ]
        [ textarea [ onInput OnInput, placeholder "# Markdown text here", value model.note.text ] []
        ]


viewPreview : Model -> Html Msg
viewPreview model =
    div [ class "app-preview" ] [ Markdown.toHtml [] model.note.text ]


viewControl : Model -> Html Msg
viewControl model =
    let
        viewSwitchModeIcon =
            if model.layoutMode == LayoutMode.Focus then
                button [ class "btn", onClick (SwitchLayout LayoutMode.Read) ]
                    [ i [ class "material-icons" ] [ text "remove_red_eye" ] ]

            else if model.layoutMode == LayoutMode.Read then
                button [ class "btn", onClick (SwitchLayout LayoutMode.Focus) ]
                    [ i [ class "material-icons" ] [ text "edit" ] ]

            else
                div [] []
    in
    div [ class "app-control" ] [ viewSwitchModeIcon ]



-- ports


port setStorage : Encode.Value -> Cmd msg


port writeFile : String -> Cmd msg


port fileLoaded : (Decode.Value -> msg) -> Sub msg


port fileWritten : (Bool -> msg) -> Sub msg


port openFile : () -> Cmd msg


themeClass : ColorTheme -> String
themeClass colorTheme =
    case colorTheme of
        ColorTheme.White ->
            "app-wrapper--white-theme"

        ColorTheme.Dark ->
            "app-wrapper--dark-theme"


appListItemClass : Bool -> String
appListItemClass isActive =
    if isActive then
        "app-list__item app-list__item--active"

    else
        "app-list__item"


layoutClass : LayoutMode -> String
layoutClass layoutMode =
    "app-container--" ++ (layoutMode |> LayoutMode.toString |> String.toLower)


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model

        newValue =
            { colorTheme = newModel.colorTheme
            , layoutMode = newModel.layoutMode
            }
    in
    ( newModel
    , Cmd.batch
        [ setStorage <| LocalStorageValue.encode newValue, cmds ]
    )



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ fileLoaded FileLoaded, fileWritten FileWritten ]



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = updateWithStorage
        , subscriptions = subscriptions
        }

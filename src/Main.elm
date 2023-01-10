port module Main exposing (Model, ModelExposedToStorage, Msg(..), appListItemClass, emptyModel, init, main, setStorage, update, updateWithStorage, view)

import Browser
import Browser.Events exposing (onKeyDown)
import ColorTheme exposing (ColorTheme)
import Html exposing (Html, button, div, fieldset, h2, input, label, legend, nav, text, textarea)
import Html.Attributes exposing (checked, class, for, id, name, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Html.Lazy exposing (lazy)
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
    , isWaitingShortcutKey : Bool
    , isSidebarOpen : Bool
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
    , isWaitingShortcutKey = False
    , isSidebarOpen = False
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
    | OnKeyDown String
    | SwitchLayout LayoutMode Bool
    | FileLoaded Decode.Value
    | FileWritten Bool
    | NewFileBuilt Decode.Value
    | TriggerSaveFile
    | ToggleTheme Bool
    | ToggleSidebar
    | OpenFile
    | NewFile


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            let
                note =
                    model.note
            in
            ( { model | note = { note | text = newBody } }
            , Cmd.batch [ changeText newBody ]
            )

        OnKeyDown key ->
            if model.isWaitingShortcutKey then
                case key of
                    "Control" ->
                        update (SwitchLayout (LayoutMode.togglePreview model.layoutMode) True) { model | isWaitingShortcutKey = False }

                    "s" ->
                        update TriggerSaveFile model

                    _ ->
                        ( { model | isWaitingShortcutKey = False }, Cmd.none )

            else
                case key of
                    "Control" ->
                        ( { model | isWaitingShortcutKey = True }, Cmd.none )

                    _ ->
                        ( { model | isWaitingShortcutKey = False }, Cmd.none )

        SwitchLayout mode _ ->
            ( { model | layoutMode = mode }, Cmd.none )

        NewFileBuilt value ->
            let
                decoded =
                    Note.decode value

                note =
                    case decoded of
                        Ok loadedNote ->
                            let
                                text =
                                    if String.isEmpty model.note.text then
                                        "# " ++ (loadedNote.name |> String.replace ".md" "")

                                    else
                                        model.note.text
                            in
                            { loadedNote | text = text }

                        Err _ ->
                            Note.new
            in
            ( { model | note = note }, Cmd.none )

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

        TriggerSaveFile ->
            case model.note.lastModified of
                Just _ ->
                    ( model, Cmd.batch [ writeFile model.note.text ] )

                Nothing ->
                    ( model, Cmd.batch [ saveFile model.note.text ] )

        ToggleTheme _ ->
            ( { model | colorTheme = ColorTheme.toggle model.colorTheme }, Cmd.none )

        ToggleSidebar ->
            ( { model | isSidebarOpen = not model.isSidebarOpen }, Cmd.none )

        OpenFile ->
            ( model, Cmd.batch [ openFile () ] )

        NewFile ->
            ( model, Cmd.batch [ newFile () ] )



---- VIEW ----
-- main view


view : Model -> Html Msg
view model =
    div [ class <| "app-wrapper " ++ themeClass model.colorTheme ]
        [ div [ class <| "app-layout " ++ layoutClass model.layoutMode ]
            [ viewEditor model
            , lazy viewPreview model.note
            , viewSidebar model
            ]
        ]


viewSidebar : Model -> Html Msg
viewSidebar model =
    let
        sidebarClassNames =
            if model.isSidebarOpen then
                "app-sidebar app-sidebar--open"

            else
                "app-sidebar app-sidebar--closed"
    in
    nav [ class sidebarClassNames ]
        [ div [ class "app-sidebar__buttons" ]
            [ button [ class "app-sidebar__button", onClick TriggerSaveFile ]
                [ div [] [ text "Save text" ]
                ]
            , button [ class "app-sidebar__button", onClick ToggleSidebar ]
                [ div []
                    [ text
                        (if model.isSidebarOpen then
                            "Close sidebar"

                         else
                            "Open sidebar"
                        )
                    ]
                ]
            ]
        , viewSidebarBody model
        ]


viewSidebarBody : Model -> Html Msg
viewSidebarBody model =
    let
        body =
            if True then
                [ div [ class "app-sidebar__body__section" ]
                    [ h2 [] [ text "File" ]
                    , div [ class "app-sidebar__body__section__buttons" ]
                        [ button [ onClick NewFile ] [ text "New" ]
                        , button [ onClick OpenFile ] [ text "Open" ]
                        ]
                    ]
                , fieldset [ class "app-sidebar__body__section" ]
                    [ legend [] [ text "Layout" ]
                    , input
                        [ type_ "radio"
                        , id "layout-radio-split"
                        , value "split"
                        , checked (model.layoutMode == LayoutMode.Write)
                        , onCheck (SwitchLayout LayoutMode.Write)
                        , class "app-sidebar__body__radio"
                        , name "layout"
                        ]
                        []
                    , label [ for "layout-radio-split" ] [ text "split" ]
                    , input
                        [ type_ "radio"
                        , id "layout-radio-edit"
                        , value "edit"
                        , checked (model.layoutMode == LayoutMode.Focus)
                        , onCheck (SwitchLayout LayoutMode.Focus)
                        , class "app-sidebar__body__radio"
                        , name "layout"
                        ]
                        []
                    , label [ for "layout-radio-edit" ] [ text "edit" ]
                    , input
                        [ type_ "radio"
                        , id "layout-radio-view"
                        , value "view"
                        , checked (model.layoutMode == LayoutMode.Read)
                        , onCheck (SwitchLayout LayoutMode.Read)
                        , class "app-sidebar__body__radio"
                        , name "layout"
                        ]
                        []
                    , label [ for "layout-radio-view" ] [ text "view" ]
                    ]
                , fieldset [ class "app-sidebar__body__section" ]
                    [ legend [] [ text "Theme" ]
                    , input
                        [ type_ "radio"
                        , id "layout-radio-white"
                        , value "white"
                        , checked (model.colorTheme == ColorTheme.White)
                        , onCheck ToggleTheme
                        , class "app-sidebar__body__radio"
                        , name "theme"
                        ]
                        []
                    , label [ for "layout-radio-white" ] [ text "white" ]
                    , input
                        [ type_ "radio"
                        , id "layout-radio-dark"
                        , value "dark"
                        , checked (model.colorTheme == ColorTheme.Dark)
                        , onCheck ToggleTheme
                        , class "app-sidebar__body__radio"
                        , name "theme"
                        ]
                        []
                    , label [ for "layout-radio-dark" ] [ text "dark" ]
                    ]
                ]

            else
                []
    in
    div [ class "app-sidebar__body" ] body


viewEditor : Model -> Html Msg
viewEditor model =
    let
        classNames =
            if model.layoutMode /= LayoutMode.Read then
                "app-editor"

            else
                "app-editor app-editor--hidden"
    in
    div [ class classNames ]
        [ textarea [ onInput OnInput, placeholder "# Markdown text here", value model.note.text ] []
        ]


viewPreview : Note -> Html Msg
viewPreview note =
    div [ class "app-preview" ] [ Markdown.toHtmlWith markdownOptions [] note.text ]


markdownOptions : Markdown.Options
markdownOptions =
    { githubFlavored = Just { tables = True, breaks = False }
    , defaultHighlighting = Nothing
    , sanitize = True
    , smartypants = False
    }


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
    "app-layout--" ++ (layoutMode |> LayoutMode.toString |> String.toLower)


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



-- ports


port changeText : String -> Cmd msg


port setStorage : Encode.Value -> Cmd msg


port writeFile : String -> Cmd msg


port saveFile : String -> Cmd msg


port openFile : () -> Cmd msg


port newFile : () -> Cmd msg


port fileLoaded : (Decode.Value -> msg) -> Sub msg


port fileWritten : (Bool -> msg) -> Sub msg


port fileBuilt : (Decode.Value -> msg) -> Sub msg


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map OnKeyDown (Decode.field "key" Decode.string)



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ fileLoaded FileLoaded, fileWritten FileWritten, fileBuilt NewFileBuilt, onKeyDown keyDecoder ]



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = updateWithStorage
        , subscriptions = subscriptions
        }

port module Main exposing (Model, ModelExposedToStorage, Msg(..), activeNote, appListItemClass, deleteNote, emptyModel, init, isActiveNote, main, newNote, savedModelToModel, setStorage, switchColorTheme, update, updateActiveNoteBody, updateWithStorage, view, viewNoteListItem)

import Browser exposing (..)
import ColorTheme exposing (ColorTheme)
import Html exposing (Html, a, aside, button, div, h1, i, img, p, text, textarea)
import Html.Attributes exposing (class, href, placeholder, src, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import LayoutMode exposing (LayoutMode)
import Markdown
import Note exposing (Note)



---- MODEL ----


type alias Model =
    { colorTheme : ColorTheme
    , listVisible : Bool
    , noteList : List Note
    , activeNoteId : Note.Id
    , layoutMode : LayoutMode
    }


type alias ModelExposedToStorage =
    { colorTheme : ColorTheme
    , listVisible : Bool
    , noteList : List Note
    , activeNoteId : Note.Id
    , layoutMode : LayoutMode
    }


emptyModel : Model
emptyModel =
    { colorTheme = ColorTheme.White
    , noteList = [ { id = 1, body = "" } ]
    , listVisible = False
    , activeNoteId = 1
    , layoutMode = LayoutMode.Write
    }



-- Decoders


noteDecoder : Decode.Decoder Note
noteDecoder =
    Decode.map2 Note
        (Decode.field "id" Decode.int)
        (Decode.field "body" Decode.string)


modelDecoder : Decode.Decoder Model
modelDecoder =
    Decode.map5 Model
        (Decode.field "colorTheme" ColorTheme.decode)
        (Decode.field "listVisible" Decode.bool)
        (Decode.field "noteList" (Decode.list noteDecoder))
        (Decode.field "activeNoteId" Decode.int)
        (Decode.field "layoutMode" LayoutMode.decode)



-- Encoders


encodeModel : Model -> Encode.Value
encodeModel model =
    Encode.object
        [ ( "colorTheme", ColorTheme.encode model.colorTheme )
        , ( "listVisible", Encode.bool model.listVisible )
        , ( "noteList", Encode.list Note.encode model.noteList )
        , ( "activeNoteId", Encode.int model.activeNoteId )
        , ( "layoutMode", LayoutMode.encode model.layoutMode )
        ]


savedModelToModel : Decode.Value -> Model
savedModelToModel savedValue =
    let
        result =
            Decode.decodeValue modelDecoder savedValue

        maybeModel =
            case result of
                Result.Ok model ->
                    Just model

                Result.Err err ->
                    Nothing
    in
    maybeModel |> Maybe.withDefault emptyModel


init : Decode.Value -> ( Model, Cmd Msg )
init savedModel =
    ( savedModelToModel savedModel, Cmd.none )



---- UPDATE ----


type Msg
    = OnInput String
    | DeleteNote Note.Id
    | ToggleNoteList
    | AddNewNote
    | OpenNote Note.Id
    | SwitchColorTheme
    | SwitchLayout LayoutMode


switchColorTheme : Model -> Model
switchColorTheme model =
    case model.colorTheme of
        ColorTheme.White ->
            { model | colorTheme = ColorTheme.Dark }

        ColorTheme.Dark ->
            { model | colorTheme = ColorTheme.White }


isActiveNote : Model -> Note.Id -> Bool
isActiveNote model id =
    model.activeNoteId == id


activeNote : Model -> Note
activeNote model =
    let
        maybeNote =
            model.noteList |> List.filter (\note -> isActiveNote model note.id) |> List.head
    in
    case maybeNote of
        Nothing ->
            Note.getFirst model.noteList

        Just note ->
            note


newNote : Model -> Maybe Note
newNote model =
    if (activeNote model).body == "" then
        Nothing

    else
        Just { id = Note.lastId model.noteList + 1, body = "# New note" }


updateActiveNoteBody : Model -> String -> Model
updateActiveNoteBody model newBody =
    let
        list =
            List.map
                (\note ->
                    if note.id == model.activeNoteId then
                        { note | body = newBody }

                    else
                        note
                )
                model.noteList
    in
    { model | noteList = list }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            let
                updated =
                    updateActiveNoteBody model newBody

                newModel =
                    { model
                        | noteList =
                            Note.excludeBlank updated.noteList model.activeNoteId
                    }
            in
            ( newModel, Cmd.none )

        DeleteNote id ->
            ( deleteNote model id, Cmd.none )

        ToggleNoteList ->
            ( { model | listVisible = not model.listVisible }, Cmd.none )

        AddNewNote ->
            let
                maybeNote =
                    newNote model
            in
            case maybeNote of
                Nothing ->
                    ( model, Cmd.none )

                Just note ->
                    ( { model | noteList = model.noteList ++ [ note ], activeNoteId = note.id }
                    , Cmd.none
                    )

        OpenNote id ->
            ( { model | activeNoteId = id }, Cmd.none )

        SwitchColorTheme ->
            ( switchColorTheme model, Cmd.none )

        SwitchLayout mode ->
            ( { model | layoutMode = mode }, Cmd.none )


deleteNote : Model -> Note.Id -> Model
deleteNote model id =
    let
        newNoteList =
            List.filter (\note -> note.id /= id) model.noteList
    in
    if List.isEmpty newNoteList then
        let
            newId =
                id + 1
        in
        -- if noteList is empty after the note deleted, open new note
        { model | noteList = [ Note.new newId ], activeNoteId = newId }

    else if model.activeNoteId == id then
        -- if active note is deleted, open last note
        { model | noteList = newNoteList, activeNoteId = Note.lastId newNoteList }

    else
        { model | noteList = newNoteList }



---- VIEW ----
-- main view


view : Model -> Html Msg
view model =
    div [ class <| "app-wrapper " ++ themeClass model.colorTheme ]
        [ div [ class <| "app-container " ++ layoutClass model.layoutMode ]
            [ viewSidebar model
            , viewNoteList model
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
            [ button [ class "app-sidebar__buttons__btn btn", onClick (SwitchLayout (model.layoutMode |> LayoutMode.toggleList)) ]
                [ i [ class "material-icons" ] [ text "list" ] ]
            , button [ class "app-sidebar__buttons__btn btn btn-control-point", onClick AddNewNote ]
                [ i [ class "material-icons" ] [ text "note_add" ] ]
            , button [ class "app-sidebar__buttons__btn btn", onClick SwitchColorTheme ]
                [ i [ class "material-icons" ] [ text "lightbulb_outline" ] ]
            , button [ class "app-sidebar__buttons__btn btn", onClick (SwitchLayout (model.layoutMode |> LayoutMode.toggleMainColumns)) ]
                [ i [ class "material-icons" ] [ text "compare" ] ]
            ]
        ]


viewNoteList : Model -> Html Msg
viewNoteList model =
    div [ class "app-list" ]
        (List.reverse <| List.map viewNoteListItem (List.map (\note -> ( note, model.activeNoteId )) model.noteList))


viewNoteListItem : ( Note, Note.Id ) -> Html Msg
viewNoteListItem ( note, activeNoteId ) =
    if note.body == "" then
        div [] []

    else
        div [ class <| appListItemClass <| activeNoteId == note.id ]
            [ a
                [ class "app-list__item__link", onClick (OpenNote note.id) ]
                [ text (note |> Note.toTitle) ]
            ]


viewEditor : Model -> Html Msg
viewEditor model =
    div [ class "app-editor" ]
        [ textarea [ onInput OnInput, placeholder "# Markdown text here", value (activeNote model).body ] []
        ]


viewPreview : Model -> Html Msg
viewPreview model =
    div [ class "app-preview" ] [ Markdown.toHtml [] (activeNote model).body ]


viewControl : Model -> Html Msg
viewControl model =
    let
        viewSwitchModeIcon =
            if model.layoutMode == LayoutMode.Write || model.layoutMode == LayoutMode.OpenAll then
                div [] []

            else if model.layoutMode == LayoutMode.Focus || model.layoutMode == LayoutMode.Modify then
                button [ class "btn", onClick (SwitchLayout (model.layoutMode |> LayoutMode.transitToPreviewMode)) ]
                    [ i [ class "material-icons" ] [ text "remove_red_eye" ] ]

            else
                button [ class "btn", onClick (SwitchLayout (model.layoutMode |> LayoutMode.transitToEditableMode)) ]
                    [ i [ class "material-icons" ] [ text "edit" ] ]
    in
    div [ class "app-control" ]
        [ button [ class "btn", onClick (DeleteNote (activeNote model).id) ]
            [ i [ class "material-icons" ] [ text "delete" ] ]
        , viewSwitchModeIcon
        ]



-- classeNames


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



-- ports


port setStorage : Decode.Value -> Cmd msg


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch
        [ setStorage <| encodeModel newModel, cmds ]
    )



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = updateWithStorage
        , subscriptions = always Sub.none
        }

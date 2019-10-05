port module Main exposing (Model, ModelExposedToStorage, Msg(..), activeNote, appListItemClass, appWrapperClassName, deleteNote, emptyModel, filterPresentNote, init, isActiveNote, listIcon, main, newNote, savedModelToModel, setStorage, switchColorTheme, update, updateActiveNoteBody, updateWithStorage, view, viewNoteListItem)

import Browser exposing (..)
import Html exposing (Html, a, aside, button, div, h1, i, img, p, text, textarea)
import Html.Attributes exposing (class, href, placeholder, src, value)
import Html.Events exposing (onClick, onInput)
import Markdown
import Note exposing (..)
import Styles
import Types exposing (..)



---- MODEL ----


type alias Model =
    { colorTheme : ColorTheme
    , listVisible : Bool
    , noteList : List Note
    , activeNoteId : Id
    }


type alias ModelExposedToStorage =
    { listVisible : Bool
    , noteList : List Note
    , activeNoteId : Int
    }


emptyModel : Model
emptyModel =
    { colorTheme = WhiteTheme
    , noteList = [ { id = 1, body = "" } ]
    , listVisible = False
    , activeNoteId = 1
    }


savedModelToModel : Maybe ModelExposedToStorage -> Model
savedModelToModel maybeSavedModel =
    case maybeSavedModel of
        Nothing ->
            emptyModel

        Just savedModel ->
            { listVisible = savedModel.listVisible
            , noteList = savedModel.noteList
            , activeNoteId = savedModel.activeNoteId
            , colorTheme = WhiteTheme
            }


init : Maybe ModelExposedToStorage -> ( Model, Cmd Msg )
init savedModel =
    ( savedModelToModel savedModel, Cmd.none )



---- UPDATE ----


type Msg
    = OnInput String
    | DeleteNote Id
    | ToggleNoteList
    | AddNewNote
    | OpenNote Id
    | SwitchColorTheme


switchColorTheme : Model -> Model
switchColorTheme model =
    case model.colorTheme of
        WhiteTheme ->
            { model | colorTheme = DarkTheme }

        DarkTheme ->
            { model | colorTheme = WhiteTheme }


isActiveNote : Model -> Id -> Bool
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
            getFirstNote model.noteList

        Just note ->
            note


newNote : Model -> Maybe Note
newNote model =
    if (activeNote model).body == "" then
        Nothing

    else
        Just { id = lastNoteId model.noteList + 1, body = "" }


updateActiveNoteBody : Model -> String -> Model
updateActiveNoteBody model newBody =
    let
        list =
            List.map
                (\note ->
                    if note.id == model.activeNoteId then
                        updateNoteBody note newBody

                    else
                        note
                )
                model.noteList
    in
    { model | noteList = list }


filterPresentNote : Model -> Model
filterPresentNote model =
    let
        list =
            List.filter (\note -> note.id == model.activeNoteId || note.body /= "") model.noteList
    in
    { model | noteList = list }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            let
                newModel =
                    updateActiveNoteBody model newBody
                        |> filterPresentNote
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


deleteNote : Model -> Id -> Model
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
        { model | noteList = [ emptyNote newId ], activeNoteId = newId }

    else if model.activeNoteId == id then
        -- if active note is deleted, open last note
        { model | noteList = newNoteList, activeNoteId = lastNoteId newNoteList }

    else
        { model | noteList = newNoteList }



---- VIEW ----


appListItemClass : Bool -> String
appListItemClass isActive =
    if isActive then
        "app-list__item app-list__item--active"

    else
        "app-list__item"


viewNoteListItem : ( Note, Id ) -> Html Msg
viewNoteListItem ( note, activeNoteId ) =
    if note.body == "" then
        div [] []

    else
        div [ class <| appListItemClass <| activeNoteId == note.id ]
            [ a
                [ class "app-list__item__link", onClick (OpenNote note.id) ]
                [ text (note |> toTitle) ]
            ]


listIcon : Bool -> String
listIcon listVisible =
    if listVisible then
        "keyboard_arrow_left"

    else
        "list"


view : Model -> Html Msg
view model =
    div [ class <| appWrapperClassName model ]
        [ div [ class "app-container" ]
            [ aside [ class "app-sidebar" ]
                [ div [ class "app-sidebar__buttons" ]
                    [ button [ class "app-sidebar__buttons__btn btn btn-list", onClick ToggleNoteList ]
                        [ i [ class "material-icons" ] [ text (listIcon model.listVisible) ] ]
                    , button [ class "app-sidebar__buttons__btn btn btn-control-point", onClick AddNewNote ]
                        [ i [ class "material-icons" ] [ text "note_add" ] ]
                    , button [ class "app-sidebar__buttons__btn btn", onClick SwitchColorTheme ]
                        [ i [ class "material-icons" ] [ text "lightbulb_outline" ] ]
                    ]
                ]
            , div (List.concat [ [ class "app-list" ], Styles.appList model.listVisible ])
                (List.reverse <| List.map viewNoteListItem (List.map (\note -> ( note, model.activeNoteId )) model.noteList))
            , div [ class "app-editor" ]
                [ textarea [ onInput OnInput, placeholder "# Markdown text here", value (activeNote model).body ] []
                ]
            , div [ class "app-preview" ]
                [ div [ class "app-preview__control" ]
                    [ button [ class "btn btn-delete", onClick (DeleteNote (activeNote model).id) ]
                        [ i [ class "material-icons" ] [ text "delete" ] ]
                    ]
                , Markdown.toHtml [] (activeNote model).body
                ]
            ]
        ]


port setStorage : ModelExposedToStorage -> Cmd msg


appWrapperClassName : Model -> String
appWrapperClassName model =
    case model.colorTheme of
        WhiteTheme ->
            "app-wrapper app-wrapper--white-theme"

        DarkTheme ->
            "app-wrapper app-wrapper--dark-theme"


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch
        [ setStorage
            { listVisible = newModel.listVisible
            , noteList = newModel.noteList
            , activeNoteId = newModel.activeNoteId
            }
        , cmds
        ]
    )



---- PROGRAM ----


main : Program (Maybe ModelExposedToStorage) Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = updateWithStorage
        , subscriptions = always Sub.none
        }

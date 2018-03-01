port module Main exposing (..)

import Html exposing (Html, a, button, div, h1, header, i, img, p, text, textarea)
import Html.Attributes exposing (class, href, placeholder, src, style, value)
import Html.Events exposing (onClick, onInput)
import Markdown
import Styles


---- MODEL ----


type alias Id =
    Int


type alias Note =
    { id : Id, body : String }


type alias Model =
    { listVisible : Bool, noteList : List Note, activeNoteId : Id }


lastNoteId : List Note -> Id
lastNoteId noteList =
    let
        note =
            List.reverse noteList |> List.head
    in
    case note of
        Nothing ->
            1

        Just note ->
            note.id


emptyModel : Model
emptyModel =
    { noteList = [ { id = 1, body = "" } ]
    , listVisible = False
    , activeNoteId = 1
    }


emptyNote : Id -> Note
emptyNote id =
    { id = id, body = "" }


init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
    Maybe.withDefault emptyModel savedModel ! []



---- UPDATE ----


type Msg
    = OnInput String
    | DeleteNote Id
    | ToggleNoteList
    | AddNewNote
    | Blur
    | OpenNote Id


type alias NoteStatusTuple =
    ( Note, Bool )


isActiveNote : Model -> Id -> Bool
isActiveNote model id =
    model.activeNoteId == id


activeNote : Model -> Note
activeNote model =
    let
        note =
            model.noteList |> List.filter (\note -> isActiveNote model note.id) |> List.head
    in
    case note of
        Nothing ->
            getFirstNote model.noteList

        Just note ->
            note


updateNoteBody : Note -> String -> Note
updateNoteBody note newBody =
    { note | body = newBody }


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
                note =
                    newNote model
            in
            case note of
                Nothing ->
                    ( model, Cmd.none )

                Just note ->
                    ( { model | noteList = model.noteList ++ [ note ], activeNoteId = note.id }
                    , Cmd.none
                    )

        Blur ->
            let
                nextModel =
                    if model.listVisible then
                        { model | listVisible = False }
                    else
                        model
            in
            ( nextModel
            , Cmd.none
            )

        OpenNote id ->
            ( { model | activeNoteId = id }, Cmd.none )


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


getFirstNote : List Note -> Note
getFirstNote list =
    let
        note =
            List.head list
    in
    case note of
        Nothing ->
            { id = 1, body = "" }

        Just note ->
            note



---- VIEW ----


viewNoteListItem : Note -> Html Msg
viewNoteListItem note =
    if note.body == "" then
        div [] []
    else
        div [ class "app-list__item" ]
            [ a
                [ onClick (OpenNote note.id) ]
                [ text (String.slice 0 30 note.body) ]
            ]


view : Model -> Html Msg
view model =
    div [ class "app-wrapper" ]
        [ div [ class "app-container", Styles.appContainer model.listVisible ]
            [ header [ class "app-header" ]
                [ h1 [ class "page-header" ]
                    [ text "Nekobito" ]
                , button [ class "btn-list", onClick ToggleNoteList ]
                    [ i [ class "material-icons" ] [ text "list" ] ]
                , button [ class "btn-control-point", onClick AddNewNote ]
                    [ i [ class "material-icons" ] [ text "control_point" ] ]
                ]
            , div [ class "app-editor", onClick Blur ]
                [ textarea [ onInput OnInput, placeholder "# Markdown text here", value (activeNote model).body ] []
                ]
            , div [ class "app-preview", onClick Blur ]
                [ div [ class "app-preview__control" ]
                    [ i [ class "material-icons", onClick (DeleteNote (activeNote model).id) ] [ text "delete" ] ]
                , Markdown.toHtml [ onClick Blur ] (activeNote model).body
                ]
            ]
        , div [ class "app-list", Styles.appList model.listVisible ]
            (List.map viewNoteListItem model.noteList)
        ]


port setStorage : Model -> Cmd msg


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ setStorage newModel, cmds ]
    )



---- PROGRAM ----


main : Program (Maybe Model) Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = updateWithStorage
        , subscriptions = always Sub.none
        }

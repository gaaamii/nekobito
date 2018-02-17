port module Main exposing (..)

import Html exposing (Html, a, button, div, h1, header, i, img, p, text, textarea)
import Html.Attributes exposing (class, href, placeholder, src, style, value)
import Html.Events exposing (onClick, onInput)
import Markdown
import Styles


---- MODEL ----


type alias Note =
    { body : String, selected : Bool }


type alias Model =
    { listVisible : Bool, noteList : List Note }


emptyModel : Model
emptyModel =
    { noteList = [ { body = "", selected = True } ]
    , listVisible = False
    }


init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
    Maybe.withDefault emptyModel savedModel ! []



---- UPDATE ----


type Msg
    = OnInput String
    | DeleteNote
    | ToggleNoteList
    | AddNewNote Note


newNote : Note -> String -> Note
newNote note newBody =
    { note | body = newBody }


isSelected : Note -> Bool
isSelected note =
    note.selected


selectedNote : Model -> Note
selectedNote model =
    let
        note =
            model.noteList |> List.filter isSelected |> List.head
    in
    case note of
        Nothing ->
            { body = "", selected = True }

        Just note ->
            note


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            let
                list =
                    [ newNote (model |> selectedNote) newBody ]
            in
            ( { model | noteList = list }, Cmd.none )

        DeleteNote ->
            ( model, Cmd.none )

        ToggleNoteList ->
            ( { model | listVisible = not model.listVisible }, Cmd.none )

        AddNewNote note ->
            ( { model | noteList = model.noteList ++ [ note ] }
            , Cmd.none
            )


getFirstNote : List Note -> Note
getFirstNote list =
    let
        note =
            List.head list
    in
    case note of
        Nothing ->
            { body = "", selected = True }

        Just note ->
            note



---- VIEW ----


viewNoteListItem : Note -> Html msg
viewNoteListItem note =
    div [ class "app-list__item" ]
        [ a [ href "#" ] [ text (String.slice 0 30 note.body) ]
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
                ]
            , div [ class "app-editor" ]
                [ textarea [ onInput OnInput, placeholder "# Markdown text here", value (getFirstNote model.noteList).body ] []
                ]
            , Markdown.toHtml [ class "app-preview" ] (getFirstNote model.noteList).body
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

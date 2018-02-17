port module Main exposing (..)

import Html exposing (Html, button, div, h1, header, i, img, p, text, textarea)
import Html.Attributes exposing (class, placeholder, src, style, value)
import Html.Events exposing (onClick, onInput)
import Markdown


---- MODEL ----


type alias Note =
    { body : String, selected : Bool }


type alias Model =
    { noteList : List Note }


emptyModel : Model
emptyModel =
    { noteList = [ { body = "", selected = True } ]
    }


init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
    Maybe.withDefault emptyModel savedModel ! []



---- UPDATE ----


type Msg
    = OnInput String
    | DeleteEntry
    | ListEntries


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

        DeleteEntry ->
            ( model, Cmd.none )

        ListEntries ->
            ( model, Cmd.none )


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


view : Model -> Html Msg
view model =
    div [ class "app-container" ]
        [ header [ class "app-header" ]
            [ h1 [ class "page-header" ]
                [ text "Nekobito" ]
            , button [ class "btn-delete", onClick DeleteEntry ]
                [ i [ class "material-icons" ] [ text "delete" ] ]
            , button [ class "btn-list", onClick ListEntries ]
                [ i [ class "material-icons" ] [ text "list" ] ]
            ]
        , div [ class "app-editor" ]
            [ textarea [ onInput OnInput, placeholder "# Markdown text here", value (getFirstNote model.noteList).body ] []
            ]
        , Markdown.toHtml [ class "app-preview" ] (getFirstNote model.noteList).body
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

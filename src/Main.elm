port module Main exposing (Model, ModelExposedToStorage, Msg(..), activeNote, appListItemClass, appWrapperClassName, deleteNote, emptyModel, init, isActiveNote, listIcon, main, newNote, savedModelToModel, setStorage, switchColorTheme, update, updateActiveNoteBody, updateWithStorage, view, viewNoteListItem)

import Browser exposing (..)
import Html exposing (Html, a, aside, button, div, h1, i, img, p, text, textarea)
import Html.Attributes exposing (class, href, placeholder, src, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import Markdown
import Note exposing (Note)
import Styles
import Types exposing (..)



---- MODEL ----


type alias Model =
    { colorTheme : ColorTheme
    , listVisible : Bool
    , noteList : List Note
    , activeNoteId : Note.Id
    }


type alias ModelExposedToStorage =
    { colorTheme : ColorTheme
    , listVisible : Bool
    , noteList : List Note
    , activeNoteId : Note.Id
    }


emptyModel : Model
emptyModel =
    { colorTheme = WhiteTheme
    , noteList = [ { id = 1, body = "" } ]
    , listVisible = False
    , activeNoteId = 1
    }



-- Decoders


noteDecoder : Decode.Decoder Note
noteDecoder =
    Decode.map2 Note
        (Decode.field "id" Decode.int)
        (Decode.field "body" Decode.string)


decodeColorTheme =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "DarkTheme" ->
                        Decode.succeed DarkTheme

                    _ ->
                        Decode.succeed WhiteTheme
            )


modelDecoder : Decode.Decoder Model
modelDecoder =
    Decode.map4 Model
        (Decode.field "colorTheme" decodeColorTheme)
        (Decode.field "listVisible" Decode.bool)
        (Decode.field "noteList" (Decode.list noteDecoder))
        (Decode.field "activeNoteId" Decode.int)



-- Encoders


noteEncoder : Note -> Encode.Value
noteEncoder note =
    Encode.object
        [ ( "id", Encode.int note.id )
        , ( "body", Encode.string note.body )
        ]


encodeColorTheme : ColorTheme -> Encode.Value
encodeColorTheme colorTheme =
    case colorTheme of
        DarkTheme ->
            Encode.string "DarkTheme"

        _ ->
            Encode.string "WhiteTheme"


encodeModel : Model -> Encode.Value
encodeModel model =
    Encode.object
        [ ( "colorTheme", encodeColorTheme model.colorTheme )
        , ( "listVisible", Encode.bool model.listVisible )
        , ( "noteList", Encode.list noteEncoder model.noteList )
        , ( "activeNoteId", Encode.int model.activeNoteId )
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

                _ ->
                    Nothing
    in
    Maybe.withDefault emptyModel maybeModel


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


switchColorTheme : Model -> Model
switchColorTheme model =
    case model.colorTheme of
        WhiteTheme ->
            { model | colorTheme = DarkTheme }

        DarkTheme ->
            { model | colorTheme = WhiteTheme }


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


appListItemClass : Bool -> String
appListItemClass isActive =
    if isActive then
        "app-list__item app-list__item--active"

    else
        "app-list__item"


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


port setStorage : Decode.Value -> Cmd msg


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

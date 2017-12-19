port module Main exposing (..)

import Html exposing (Html, button, div, h1, header, i, img, p, text, textarea)
import Html.Attributes exposing (class, placeholder, src, style, value)
import Html.Events exposing (onClick, onInput)
import Markdown


---- MODEL ----


type alias Model =
    { body : String }


emptyModel : Model
emptyModel =
    { body = ""
    }


init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
    Maybe.withDefault emptyModel savedModel ! []



---- UPDATE ----


type Msg
    = OnInput String
    | DeleteEntry
    | ListEntries


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            ( { model | body = newBody }, Cmd.none )

        DeleteEntry ->
            ( model, Cmd.none )

        ListEntries ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "app-wrapper" ]
        [ header [ class "app-header" ]
            [ h1 [ style [ ( "font-size", "1em" ), ( "color", "#555" ) ] ]
                [ text "Nekobito" ]
            ]
        , div [ class "app-container" ]
            [ div [ class "app-editor" ]
                [ textarea [ onInput OnInput, placeholder "# Markdown text here", value model.body ] []
                ]
            , Markdown.toHtml [ class "app-preview" ] model.body
            , button [ class "btn-delete", onClick DeleteEntry ]
                [ i [ class "material-icons" ] [ text "delete" ] ]
            , button [ class "btn-list", onClick ListEntries ]
                [ i [ class "material-icons" ] [ text "view_list" ] ]
            ]
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

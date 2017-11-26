port module Main exposing (..)

import Html exposing (Html, text, div, img, header, p, textarea, button)
import Html.Attributes exposing (src, class, placeholder, value)
import Html.Events exposing (onInput)
import Markdown

---- MODEL ----
type alias Model =
  { body: String }

emptyModel : Model
emptyModel =
  {
    body = ""
  }

init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
  Maybe.withDefault emptyModel savedModel ! []

---- UPDATE ----
type Msg
  = OnInput String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnInput newBody -> 
      ( { model | body = newBody }, Cmd.none )

---- VIEW ----
view : Model -> Html Msg
view model =
  div [ class "app-wrapper" ]
    [ header [ class "app-header" ]
      [ p []
        [ text "Nekobito - A Markdown Text Editor on Browser"
        , button [ class "btn-list" ] [ text "List" ]
        , button [ class "btn-delete" ] [ text "Delete" ]
        ]
      ]
    , div [ class "app-container" ]
        [ div [ class "app-editor" ]
          [ textarea [ onInput OnInput, placeholder "# Markdown text here" , value model.body ] []
          ]
        , Markdown.toHtml [ class "app-preview" ] model.body
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

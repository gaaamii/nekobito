module Main exposing (..)

import Html exposing (Html, text, div, img, header, p, textarea)
import Html.Attributes exposing (src, class, placeholder)
import Html.Events exposing (onInput)
import Markdown

---- MODEL ----
type alias Model =
  { body: String }


init : ( Model, Cmd Msg )
init =
  ( { body = "" }, Cmd.none )

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
        [ text "Nekobito - A Markdown Text Editor on Browser" ]
      ]
    , div [ class "app-container" ]
        [ div [ class "app-editor" ]
          [ textarea [ onInput OnInput, placeholder "# Markdown text here" ] []
          ]
        , Markdown.toHtml [ class "app-preview" ] model.body
        ]
      ]

---- PROGRAM ----
main : Program Never Model Msg
main =
  Html.program
    { view = view
    , init = init
    , update = update
    , subscriptions = always Sub.none
    }

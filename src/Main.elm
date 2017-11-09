module Main exposing (..)

import Html exposing (Html, text, div, h1, img, header, p, textarea)
import Html.Attributes exposing (src, class)
import Markdown exposing (..)

---- MODEL ----
type alias Model =
  { body: String }


init : ( Model, Cmd Msg )
init =
  ( { body = "# test" }, Cmd.none )

---- UPDATE ----


type Msg
  = NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )

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
          [ textarea [] 
            [ text model.body ]
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

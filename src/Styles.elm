module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Types exposing (..)
import List exposing (..)


appContainer : Bool -> List (Attribute msg)
appContainer isVisible =
    if isVisible then
        [
          style "margin-left" "0"
          , style "width" "80%"
        ]
    else
        [ style "margin-left" "0" ]


type alias ColorStyles =
    { color : String, background : String }


appListColorStyles : ColorTheme -> ColorStyles
appListColorStyles colorTheme =
    if colorTheme == DarkTheme then
        { color = "#fff", background = "#363636" }
    else
        { color = "#333", background = "#fafafa" }


appList : ( Bool, ColorTheme ) -> List (Attribute msg)
appList ( isVisible, colorTheme ) =
    let
        baseStyles =
            let
                colors =
                    appListColorStyles colorTheme
            in
            [
              style "position" "absolute"
              , style "width" "20%"
              , style "height" "100%"
              , style "top" "0"
              , style "font-size" ".8em"
              , style "text-align" "center"
              , style "background" colors.background
              , style "color" colors.color
            ]
    in
    if isVisible then
        List.concat [[ style "right" "0" ], baseStyles]
    else
        List.concat [[ style "right" "-20%" ], baseStyles]

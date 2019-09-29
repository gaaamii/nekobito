module Styles exposing (ColorStyles, appList, appListColorStyles)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import List exposing (..)
import Types exposing (..)


type alias ColorStyles =
    { color : String, background : String }


appListColorStyles : ColorTheme -> ColorStyles
appListColorStyles colorTheme =
    if colorTheme == DarkTheme then
        { color = "#fff", background = "#363636" }

    else
        { color = "#333", background = "#fff" }


appList : ( Bool, ColorTheme ) -> List (Attribute msg)
appList ( isVisible, colorTheme ) =
    let
        baseStyles =
            let
                colors =
                    appListColorStyles colorTheme
            in
            [ style "height" "100%"
            , style "font-size" ".8em"
            , style "text-align" "center"
            , style "background" colors.background
            , style "color" colors.color
            ]
    in
    if isVisible then
        List.concat [ [ style "width" "250px" ], baseStyles ]

    else
        List.concat [ [ style "width" "0" ], baseStyles ]

module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Types exposing (..)


appContainer : Bool -> Attribute msg
appContainer isVisible =
    if isVisible then
        style <|
            [ ( "margin-left", "0" )
            , ( "width", "80%" )
            ]
    else
        style <| [ ( "margin-left", "0" ) ]


type alias ColorStyles =
    { color : String, background : String }


appListColorStyles : ColorTheme -> ColorStyles
appListColorStyles colorTheme =
    if colorTheme == DarkTheme then
        { color = "#fff", background = "#363636" }
    else
        { color = "#333", background = "#fafafa" }


appList : ( Bool, ColorTheme ) -> Attribute msg
appList ( isVisible, colorTheme ) =
    let
        baseStyles =
            let
                colors =
                    appListColorStyles colorTheme
            in
            [ ( "position", "absolute" )
            , ( "width", "20%" )
            , ( "height", "100%" )
            , ( "top", "0" )
            , ( "right", "-20%" )
            , ( "font-size", ".8em" )
            , ( "text-align", "center" )
            , ( "background", colors.background )
            , ( "color", colors.color )
            ]
    in
    if isVisible then
        style <| baseStyles ++ [ ( "right", "0" ) ]
    else
        style <| baseStyles ++ [ ( "right", "-20%" ) ]

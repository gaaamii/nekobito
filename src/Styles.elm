module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)


appContainer : Bool -> Attribute msg
appContainer isVisible =
    if isVisible then
        style <| [ ( "margin-left", "-40%" ) ]
    else
        style <| [ ( "margin-left", "0" ) ]


appList : Bool -> Attribute msg
appList isVisible =
    let
        baseStyles =
            [ ( "position", "absolute" )
            , ( "width", "40%" )
            , ( "height", "100%" )
            , ( "background", "#333" )
            , ( "top", "0" )
            , ( "right", "-40%" )
            , ( "color", "#fff" )
            , ( "text-align", "center" )
            ]
    in
    if isVisible then
        style <| baseStyles ++ [ ( "right", "0" ) ]
    else
        style <| baseStyles ++ [ ( "right", "-40%" ) ]

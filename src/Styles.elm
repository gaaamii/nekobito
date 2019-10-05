module Styles exposing (appList)

import Html exposing (Attribute)
import Html.Attributes exposing (class)
import List exposing (..)
import Types exposing (..)


appList : Bool -> List (Attribute msg)
appList isVisible =
    if isVisible then
        [ class "app-list--visible" ]

    else
        []

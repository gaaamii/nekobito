module Common.PullDown exposing (Children(..), Id, Msg(..), empty, rootLevel, view)

import Html exposing (Html, div, li, span, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type alias Id =
    String


type Msg
    = OnClick Id


type alias PullDown =
    { id : Id
    , label : String
    , children : Children
    , checked : Bool
    }


type Children
    = Children (List PullDown)


rootLevel : Int
rootLevel =
    1


view : List PullDown -> Int -> Html Msg
view pullDowns level =
    let
        classes =
            classList
                [ ( "app-pulldown--level-" ++ String.fromInt level, True )
                , ( "app-pulldown__children", level > 1 )
                ]
    in
    ul [ classes ] <| List.map (viewPullDown level) pullDowns


viewPullDown : Int -> PullDown -> Html Msg
viewPullDown level pullDown =
    case pullDown.children of
        Children [] ->
            if pullDown.checked then
                li [ classList [ ( "app-pulldown--checked", pullDown.checked ) ] ]
                    [ text pullDown.label
                    , span [ class "material-icons", Html.Attributes.style "font-size" "16px" ] [ text "check" ]
                    ]

            else
                li [ classList [ ( "app-pulldown--checked", pullDown.checked ) ], onClick (OnClick pullDown.id) ]
                    [ text pullDown.label ]

        Children children ->
            if level > 1 then
                li []
                    [ div [ class "app-pulldown__label" ] [ text pullDown.label ]
                    , span [ class "material-icons" ] [ text "arrow_right" ]
                    , view children (level + 1)
                    ]

            else
                li []
                    [ div [ class "app-pulldown__label" ] [ text pullDown.label ]
                    , view children (level + 1)
                    ]


empty : Children
empty =
    Children []

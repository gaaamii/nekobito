module Common.PullDown exposing (Children(..), empty, view)

import Html exposing (Html, li, span, text, ul)


type alias PullDown =
    { label : String
    , children : Children
    }


type Children
    = Children (List PullDown)


view : List PullDown -> Html msg
view pullDowns =
    ul [] (List.map viewPullDown pullDowns)


viewPullDown : PullDown -> Html msg
viewPullDown pullDown =
    case pullDown.children of
        Children [] ->
            li []
                [ text pullDown.label
                ]

        Children children ->
            li []
                [ span [] [ text pullDown.label ]
                , view children
                ]


empty : Children
empty =
    Children []

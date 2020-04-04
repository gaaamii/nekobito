module Common.Modal exposing (view)

import Html exposing (Html, button, div, h2, i, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias Props msg =
    { visible : Bool
    , title : String
    , children : Html msg
    }


view : Props closeMsg -> closeMsg -> Html closeMsg
view props msg =
    if props.visible then
        div [ class "app-modal" ]
            [ div [ class "app-modal__overlay" ]
                [ div [ class "app-modal__body" ]
                    [ h2 [ class "app-modal__body__header" ]
                        [ span [ class "app-modal__body__header__text" ]
                            [ text props.title ]
                        , button [ class "btn app-modal__body__header__button", onClick msg ]
                            [ i [ class "material-icons" ] [ text "close" ]
                            ]
                        ]
                    , props.children
                    ]
                ]
            ]

    else
        div [] []

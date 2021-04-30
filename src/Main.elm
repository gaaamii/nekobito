port module Main exposing (Model, ModelExposedToStorage, Msg(..), appListItemClass, emptyModel, init, main, setStorage, update, updateWithStorage, view)

import Browser
import ColorTheme exposing (ColorTheme)
import Common.PullDown as PullDown exposing (Msg)
import Html exposing (Html, button, div, header, i, nav, text, textarea)
import Html.Attributes exposing (class, placeholder, title, value)
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode
import Json.Encode as Encode
import LayoutMode exposing (LayoutMode)
import LocalStorageValue
import Markdown
import Note exposing (Note)



---- MODEL ----


type alias Model =
    { colorTheme : ColorTheme
    , note : Note
    , layoutMode : LayoutMode
    }


type alias ModelExposedToStorage =
    { colorTheme : ColorTheme
    , layoutMode : LayoutMode
    }


emptyModel : Model
emptyModel =
    { colorTheme = ColorTheme.White
    , note = Note.new
    , layoutMode = LayoutMode.Write
    }


buildModelFrom : Decode.Value -> Model
buildModelFrom value =
    let
        decoded =
            value |> LocalStorageValue.decode

        maybeValue =
            case decoded of
                Result.Ok v ->
                    Just v

                Result.Err _ ->
                    Nothing

        decodedValue =
            maybeValue
                |> Maybe.withDefault { layoutMode = emptyModel.layoutMode, colorTheme = emptyModel.colorTheme }
    in
    { emptyModel | layoutMode = decodedValue.layoutMode, colorTheme = decodedValue.colorTheme }


init : Decode.Value -> ( Model, Cmd Msg )
init value =
    ( buildModelFrom value, Cmd.none )



---- UPDATE ----


type Msg
    = OnInput String
    | SwitchLayout LayoutMode
    | FileLoaded Decode.Value
    | FileWritten Bool
    | NewFileBuilt Decode.Value
    | GotPullDownMsg PullDown.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnInput newBody ->
            let
                note =
                    model.note
            in
            ( { model | note = { note | text = newBody } }
            , Cmd.batch [ changeText newBody ]
            )

        SwitchLayout mode ->
            ( { model | layoutMode = mode }, Cmd.none )

        NewFileBuilt value ->
            let
                decoded =
                    Note.decode value

                note =
                    case decoded of
                        Ok loadedNote ->
                            let
                                text =
                                    if String.isEmpty model.note.text then
                                        "# " ++ (loadedNote.name |> String.replace ".md" "")

                                    else
                                        model.note.text
                            in
                            { loadedNote | text = text }

                        Err _ ->
                            Note.new
            in
            ( { model | note = note }, Cmd.none )

        FileLoaded value ->
            let
                decoded =
                    Note.decode value

                note =
                    case decoded of
                        Ok loadedNote ->
                            loadedNote

                        Err _ ->
                            Note.new
            in
            ( { model | note = note }, Cmd.none )

        FileWritten _ ->
            ( model, Cmd.none )

        GotPullDownMsg (PullDown.OnClick id) ->
            case id of
                "File/New" ->
                    ( model, Cmd.batch [ newFile () ] )

                "File/Open" ->
                    ( model, Cmd.batch [ openFile () ] )

                "File/Save" ->
                    case model.note.lastModified of
                        Just _ ->
                            ( model, Cmd.batch [ writeFile model.note.text ] )

                        Nothing ->
                            ( model, Cmd.batch [ saveFile model.note.text ] )

                "View/Theme/Dark" ->
                    ( { model | colorTheme = ColorTheme.Dark }, Cmd.none )

                "View/Theme/White" ->
                    ( { model | colorTheme = ColorTheme.White }, Cmd.none )

                "View/Layout/Split" ->
                    ( { model | layoutMode = LayoutMode.Write }, Cmd.none )

                "View/Layout/Single" ->
                    ( { model | layoutMode = LayoutMode.Focus }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



---- VIEW ----
-- main view


view : Model -> Html Msg
view model =
    div [ class <| "app-wrapper " ++ themeClass model.colorTheme ]
        [ viewNavigation model
        , div [ class <| "app-layout " ++ layoutClass model.layoutMode ]
            [ viewEditor model
            , lazy viewPreview model.note
            , viewControl model
            ]
        ]



-- sub views


viewNavigation : Model -> Html Msg
viewNavigation model =
    let
        filePullDown =
            { id = "File"
            , label = "File"
            , checked = False
            , children =
                PullDown.Children
                    [ { id = "File/New"
                      , label = "New"
                      , children = PullDown.empty
                      , checked = False
                      }
                    , { id = "File/Open"
                      , label = "Open"
                      , children = PullDown.empty
                      , checked = False
                      }
                    , { id = "File/Save"
                      , label = "Save"
                      , children = PullDown.empty
                      , checked = False
                      }
                    ]
            }

        viewPullDown =
            { id = "View"
            , label = "View"
            , checked = False
            , children =
                PullDown.Children
                    [ { id = "View/Layout"
                      , label = "Layout"
                      , children =
                            PullDown.Children
                                [ { id = "View/Layout/Split"
                                  , label = "Split"
                                  , children = PullDown.empty
                                  , checked = model.layoutMode == LayoutMode.Write
                                  }
                                , { id = "View/Layout/Single"
                                  , label = "Single"
                                  , children = PullDown.empty
                                  , checked = model.layoutMode == LayoutMode.Focus || model.layoutMode == LayoutMode.Read
                                  }
                                ]
                      , checked = False
                      }
                    , { id = "View/Theme"
                      , label = "Theme"
                      , children =
                            PullDown.Children
                                [ { id = "View/Theme/Dark"
                                  , label = "Dark"
                                  , children = PullDown.empty
                                  , checked = model.colorTheme == ColorTheme.Dark
                                  }
                                , { id = "View/Theme/White"
                                  , label = "White"
                                  , children = PullDown.empty
                                  , checked = model.colorTheme == ColorTheme.White
                                  }
                                ]
                      , checked = False
                      }
                    ]
            }
    in
    header [ class "app-navigation" ]
        [ nav []
            [ Html.map GotPullDownMsg <|
                PullDown.view
                    [ filePullDown, viewPullDown ]
                    PullDown.rootLevel
            ]
        ]


viewEditor : Model -> Html Msg
viewEditor model =
    div [ class "app-editor" ]
        [ textarea [ onInput OnInput, placeholder "# Markdown text here", value model.note.text ] []
        ]


viewPreview : Note -> Html Msg
viewPreview note =
    div [ class "app-preview" ] [ Markdown.toHtml [] note.text ]


viewControl : Model -> Html Msg
viewControl model =
    let
        viewSwitchModeIcon =
            if model.layoutMode == LayoutMode.Focus then
                button [ class "btn", onClick (SwitchLayout LayoutMode.Read) ]
                    [ i [ class "material-icons", title "Preview" ] [ text "remove_red_eye" ] ]

            else if model.layoutMode == LayoutMode.Read then
                button [ class "btn", onClick (SwitchLayout LayoutMode.Focus) ]
                    [ i [ class "material-icons", title "Edit" ] [ text "edit" ] ]

            else
                div [] []
    in
    div [ class "app-control" ] [ viewSwitchModeIcon ]


themeClass : ColorTheme -> String
themeClass colorTheme =
    case colorTheme of
        ColorTheme.White ->
            "app-wrapper--white-theme"

        ColorTheme.Dark ->
            "app-wrapper--dark-theme"


appListItemClass : Bool -> String
appListItemClass isActive =
    if isActive then
        "app-list__item app-list__item--active"

    else
        "app-list__item"


layoutClass : LayoutMode -> String
layoutClass layoutMode =
    "app-layout--" ++ (layoutMode |> LayoutMode.toString |> String.toLower)


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model

        newValue =
            { colorTheme = newModel.colorTheme
            , layoutMode = newModel.layoutMode
            }
    in
    ( newModel
    , Cmd.batch
        [ setStorage <| LocalStorageValue.encode newValue, cmds ]
    )



-- ports


port changeText : String -> Cmd msg


port setStorage : Encode.Value -> Cmd msg


port writeFile : String -> Cmd msg


port saveFile : String -> Cmd msg


port fileLoaded : (Decode.Value -> msg) -> Sub msg


port fileWritten : (Bool -> msg) -> Sub msg


port fileBuilt : (Decode.Value -> msg) -> Sub msg


port openFile : () -> Cmd msg


port newFile : () -> Cmd msg



---- Subscriptions ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ fileLoaded FileLoaded, fileWritten FileWritten, fileBuilt NewFileBuilt ]



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = updateWithStorage
        , subscriptions = subscriptions
        }

module Tests exposing (..)

import Expect
import Main exposing (..)
import Test exposing (..)


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


all : Test
all =
    describe "Main"
        [ describe "getFirstNote"
            [ test "最初のNoteを取得" <|
                \_ ->
                    let
                        subject =
                            getFirstNote [ { body = "first note", selected = False }, { body = "second note", selected = True } ]
                    in
                    Expect.equal subject { body = "first note", selected = False }
            ]
        , describe "selectedNote"
            [ test "選択中のNoteを取得" <|
                \_ ->
                    let
                        subject =
                            selectedNote
                                { noteList =
                                    [ { body = "This is not selected", selected = False }
                                    , { body = "This note is selected", selected = True }
                                    ]
                                }
                    in
                    Expect.equal subject.body "This note is selected"
            ]
        ]

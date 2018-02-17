module Tests exposing (..)

import Expect
import Main exposing (..)
import Test exposing (..)


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


all : Test
all =
    describe "Main"
        [ describe "getFirstNote"
            [ test "get first note" <|
                \_ ->
                    let
                        subject =
                            getFirstNote [ { body = "first note", selected = False }, { body = "second note", selected = True } ]
                    in
                    Expect.equal subject.body "first note"
            ]
        , describe "selectedNote"
            [ test "get selected note" <|
                \_ ->
                    let
                        subject =
                            selectedNote
                                { listVisible = False
                                , noteList =
                                    [ { body = "This is not selected", selected = False }
                                    , { body = "This note is selected", selected = True }
                                    ]
                                }
                    in
                    Expect.equal subject.body "This note is selected"
            ]
        ]

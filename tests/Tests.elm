module Tests exposing (..)

import Expect
import Main exposing (..)
import Test exposing (..)


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


dummyModel : Main.Model
dummyModel =
    { listVisible = False
    , activeNoteId = 1
    , noteList = [ { id = 1, body = "This is not active" } ]
    }


emptyNoteModel : Main.Model
emptyNoteModel =
    { listVisible = False
    , activeNoteId = 1
    , noteList = [ { id = 1, body = "" } ]
    }


all : Test
all =
    describe "Main"
        [ describe "getFirstNote"
            [ test "get first note" <|
                \_ ->
                    let
                        subject =
                            getFirstNote [ { id = 1, body = "first note" }, { id = 2, body = "second note" } ]
                    in
                    Expect.equal subject.body "first note"
            ]
        , describe "activeNote"
            [ test "get active note" <|
                \_ ->
                    let
                        subject =
                            activeNote
                                { listVisible = False
                                , activeNoteId = 2
                                , noteList =
                                    [ { id = 1, body = "This is not active" }
                                    , { id = 2, body = "This note is active" }
                                    ]
                                }
                    in
                    Expect.equal subject.body "This note is active"
            ]
        , describe "newNote"
            [ test "modelを渡すと新しいノートに自動連番で新しいidを振って返す" <|
                \_ ->
                    let
                        note =
                            newNote dummyModel
                    in
                    case note of
                        Nothing ->
                            -- This path shouldn't  be reached
                            -- when note.body is empty.
                            -- That's why this is expected to be fail.
                            Expect.equal True False

                        Just subject ->
                            Expect.equal subject.id 2
            , test "選択中のノートの本体が空白の場合は新しいノートをつくらないこと" <|
                \_ ->
                    let
                        subject =
                            newNote emptyNoteModel
                    in
                    Expect.equal subject Nothing
            ]
        ]

module Tests exposing (..)

import Expect
import Main exposing (..)
import Test exposing (..)


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


dummyModel : Model
dummyModel =
    { listVisible = False
    , activeNoteId = 1
    , noteList = [ { id = 1, body = "This is active" } ]
    }


dummyModelWithOneNote : Model
dummyModelWithOneNote =
    { listVisible = False
    , activeNoteId = 1
    , noteList = [ { id = 1, body = "This is active" } ]
    }


dummyModelWithTwoNotes : Model
dummyModelWithTwoNotes =
    { listVisible = False
    , activeNoteId = 1
    , noteList =
        [ { id = 1, body = "This is active" }
        , { id = 2, body = "This is not active" }
        ]
    }


dummyModelWithThreeNotes : Model
dummyModelWithThreeNotes =
    { listVisible = False
    , activeNoteId = 1
    , noteList =
        [ { id = 1, body = "This is active" }
        , { id = 2, body = "This is not active" }
        , { id = 3, body = "This is not active" }
        ]
    }


dummyModelWithEmptyNote : Model
dummyModelWithEmptyNote =
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
                            newNote dummyModelWithEmptyNote
                    in
                    Expect.equal subject Nothing
            ]
        , describe "deleteNote"
            [ test "1件のとき, 指定したIDのノートを消して新しい空のノートを作成して開く" <|
                \_ ->
                    let
                        subject =
                            deleteNote dummyModelWithOneNote 1
                    in
                    Expect.equal subject dummyModelWithEmptyNote
            , test "3件のとき, 現在開いてるノートを消すと最新（最後）のノートを開く" <|
                \_ ->
                    let
                        subject =
                            let
                                currentActiveNoteId =
                                    1
                            in
                            (deleteNote dummyModelWithThreeNotes currentActiveNoteId).activeNoteId
                    in
                    Expect.equal subject 3
            , test "3件のとき, 現在開いてないノートを消すと開いているノートはそのまま" <|
                \_ ->
                    let
                        subject =
                            let
                                currentActiveNoteId =
                                    1
                            in
                            (deleteNote dummyModelWithThreeNotes 2).activeNoteId
                    in
                    Expect.equal subject 1
            ]
        ]

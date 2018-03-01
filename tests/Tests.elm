module Tests exposing (..)

import Expect
import Main exposing (..)
import Test exposing (..)


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
            [ test "Get first note" <|
                \_ ->
                    let
                        subject =
                            getFirstNote [ { id = 1, body = "first note" }, { id = 2, body = "second note" } ]
                    in
                    Expect.equal subject.body "first note"
            ]
        , describe "activeNote"
            [ test "Get active note" <|
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
            [ test "Return new note with an automatic serial number as id" <|
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
            , test "Not to create new note if active note's body is empty" <|
                \_ ->
                    let
                        subject =
                            newNote dummyModelWithEmptyNote
                    in
                    Expect.equal subject Nothing
            ]
        , describe "filterPresentNote"
            [ test "Get only notes those bodies are present" <|
                \_ ->
                    let
                        subject =
                            let
                                notes =
                                    filterPresentNote
                                        [ { id = 1, body = "" }
                                        , { id = 2, body = "This note is active" }
                                        , { id = 3, body = "This note is not active" }
                                        ]
                            in
                            List.map (\note -> note.id) notes
                    in
                    Expect.equal subject [ 2, 3 ]
            ]
        , describe "deleteNote"
            [ test "With one note, create new one and open it after the note specified by id is deleted" <|
                \_ ->
                    let
                        subject =
                            deleteNote dummyModelWithOneNote 1
                    in
                    Expect.equal subject dummyModelWithEmptyNote
            , test "With three notes, open last note in the noteList if current active note is deleted" <|
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
            , test "With three notes, activeNoteId is not changed if an inactive note is deleted" <|
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

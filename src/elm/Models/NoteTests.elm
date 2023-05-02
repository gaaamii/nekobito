module Models.NoteTests exposing (..)

import Expect
import Json.Encode as Encode
import Models.Note as Note
import Test exposing (Test, describe, test)


defaultNote : Note.Note
defaultNote =
    Note.new


suite : Test
suite =
    describe "Note"
        [ describe "decode"
            [ test "decode JSON value into note" <|
                \_ ->
                    let
                        value =
                            Encode.object
                                [ ( "name", Encode.string "note name" )
                                , ( "lastModified", Encode.int 1677303425173 )
                                , ( "text", Encode.string "note content" )
                                ]
                    in
                    case Note.decode value of
                        Result.Ok v ->
                            Expect.equal v { name = "note name", lastModified = Just 1677303425173, text = "note content" }

                        Result.Err _ ->
                            Expect.fail "failed to decode JSON value into note"
            ]
        , describe "getHeadingFromFilename"
            [ test "get heading text from filename as markdown" <|
                \_ ->
                    let
                        note =
                            { defaultNote | name = "note filename.md" }
                    in
                    Expect.equal (Note.getHeadingFromFilename note) "# note filename"
            ]
        ]

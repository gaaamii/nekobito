module Note exposing (Id, Note, NoteStatusTuple, emptyNote, getFirstNote, lastNoteId, updateNoteBody)


type alias Id =
    Int


type alias Note =
    { id : Id, body : String }


lastNoteId : List Note -> Id
lastNoteId noteList =
    let
        maybeNote =
            List.reverse noteList |> List.head
    in
    case maybeNote of
        Nothing ->
            1

        Just note ->
            note.id


emptyNote : Id -> Note
emptyNote id =
    { id = id, body = "" }


type alias NoteStatusTuple =
    ( Note, Bool )


updateNoteBody : Note -> String -> Note
updateNoteBody note newBody =
    { note | body = newBody }


getFirstNote : List Note -> Note
getFirstNote list =
    let
        maybeNote =
            List.head list
    in
    case maybeNote of
        Nothing ->
            { id = 1, body = "" }

        Just note ->
            note

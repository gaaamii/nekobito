-- Types


module Note exposing (Id, Note, excludeBlank, getFirst, lastId, new, toTitle)


type alias Id =
    Int


type alias Note =
    { id : Id, body : String }



-- Constructor


new : Id -> Note
new id =
    { id = id, body = "" }



-- List Note


lastId : List Note -> Id
lastId noteList =
    List.reverse noteList
        |> List.head
        |> Maybe.withDefault (new 1)
        |> .id


getFirst : List Note -> Note
getFirst list =
    List.head list
        |> Maybe.withDefault (new 1)



-- Note


toTitle : Note -> String
toTitle note =
    note.body
        |> String.lines
        |> List.head
        |> Maybe.withDefault ""
        |> String.replace "#" ""


excludeBlank : List Note -> Id -> List Note
excludeBlank list activeId =
    list
        |> List.filter (\note -> note.id == activeId || note.body /= "")

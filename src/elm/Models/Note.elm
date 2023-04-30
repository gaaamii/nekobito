-- Types


module Models.Note exposing (Id, Note, decode, new)

import Json.Decode as Decode


type alias Id =
    Int


type alias Note =
    { name : String
    , lastModified : Maybe Int
    , text : String
    }



-- Constructor


new : Note
new =
    { name = "text.md", lastModified = Nothing, text = "" }



-- Note


decode : Decode.Value -> Result Decode.Error Note
decode value =
    let
        decoder =
            Decode.map3 Note
                (Decode.field "name" Decode.string)
                (Decode.field "lastModified" (Decode.int |> Decode.nullable))
                (Decode.field "text" Decode.string)
    in
    Decode.decodeValue decoder value

module Tests exposing (all)

import Expect
import Main exposing (..)
import Test exposing (..)


all : Test
all =
    describe "Main"
        [ describe "notest"
            [ test "Just pass." <|
                \_ ->
                    Expect.equal True True
            ]
        ]

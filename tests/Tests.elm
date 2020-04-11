module Tests exposing (all)

import Expect
import Test exposing (Test, describe, test)


all : Test
all =
    describe "Main"
        [ describe "notest"
            [ test "Just pass." <|
                \_ ->
                    Expect.equal True True
            ]
        ]

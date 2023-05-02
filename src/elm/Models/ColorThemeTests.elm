module Models.ColorThemeTests exposing (..)

import Expect
import Models.ColorTheme as ColorTheme
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "ColorTheme"
        [ describe "toClassName"
            [ test "returns a white classname as string" <|
                \_ ->
                    Expect.equal (ColorTheme.toClassName ColorTheme.White) "app-wrapper--white-theme"
            , test "returns a dark classname as string" <|
                \_ ->
                    Expect.equal (ColorTheme.toClassName ColorTheme.Dark) "app-wrapper--dark-theme"
            ]
        ]

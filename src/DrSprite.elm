module DrSprite exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Keyboard exposing (Key(..))



{- (1) - Sprite Sheet
   x, y -> the coordinates of the image on the sprite sheet
   width, height -> the size of the image I want
   adjustX, adjustY -> adjustX and adjustY move the position of the rendered image so that we can line it up with the previous frames.
   flipX, flipY ->  The sprite sheet only shows mario looking in one direction.  Though we can flip that image if we need to!
-}


type alias Box =
    { x : Int
    , y : Int
    , width : Int
    , height : Int
    , adjustX : Int
    , adjustY : Int
    , flipX : Bool
    , flipY : Bool
    }


viewSprite : Box -> Html msg
viewSprite box =
    Html.div []
        [ Html.div
            [ style "position" "absolute"
            , style "top" (String.fromInt box.adjustY ++ "px")
            , style "left" (String.fromInt box.adjustX ++ "px")
            , style "width" (String.fromInt box.width ++ "px")
            , style "height" (String.fromInt box.height ++ "px")
            , style "background-image" "url('0x72_DungeonTilesetII_v1.4.png')"
            , style "background-repeat" "no-repeat"
            , style "transform-origin" "30% 50%"
            , style "transform"
                (if box.flipX then
                    "scaleX(-1) scale(2)"

                 else
                    "scaleX(1) scale(2)"
                )
            , style "background-position"
                ("-"
                    ++ (String.fromInt box.x ++ "px -")
                    ++ (String.fromInt box.y ++ "px")
                )

            -- we need to tell the browser to render our image and leave the pixels pixelated.
            , class "pixel-art"
            ]
            []
        ]


sprite =
    { knife =
        { x = 293
        , y = 18
        , width = 6
        , height = 13
        , adjustX = 4
        , adjustY = 4
        , flipX = False
        , flipY = False
        }
    , lizard =
        { stand1 =
            { x = 128
            , y = 196
            , width = 16
            , height = 28
            , adjustX = 4
            , adjustY = 4
            , flipX = False
            , flipY = False
            }
        , stand2 =
            { x = 144
            , y = 196
            , width = 16
            , height = 28
            , adjustX = 4
            , adjustY = 4
            , flipX = False
            , flipY = False
            }
        , step2 =
            { x = 60
            , y = 240
            , width = 27
            , height = 30
            , adjustX = 4
            , adjustY = 0
            , flipX = False
            , flipY = False
            }
        , jump =
            { x = 90
            , y = 240
            , width = 27
            , height = 30
            , adjustX = 4
            , adjustY = 0
            , flipX = False
            , flipY = False
            }
        }
    }

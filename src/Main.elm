module Main exposing (..)

import Animator
import Browser
import Browser.Events
import DrParticle exposing (..)
import DrSprite exposing (..)
import Html exposing (Html)
import Html.Attributes as Attrs exposing (style)
import Json.Decode as Decode
import Keyboard exposing (Key(..))
import Keyboard.Arrows
import Particle exposing (direction)
import Particle.System as System exposing (System)
import Random
import Time


type alias GameObject =
    { ani : Animator.Timeline GameCharacter
    , x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


type alias Window =
    { width : Int
    , height : Int
    }


type alias Model =
    { system : System Confetti
    , mouse : ( Float, Float )
    , pressedKeys : List Key
    , liz : GameObject
    , window : Window
    }


type Msg
    = TriggerBurst
    | MouseMove Float Float
    | ParticleMsg (System.Msg Confetti)
    | Tick Time.Posix
    | Frame Float
    | KeyMsg Keyboard.Msg


type GameCharacter
    = GameCharacter Action Direction


init : Model
init =
    { system = System.init (Random.initialSeed 0)
    , mouse = ( 0, 0 )
    , pressedKeys = []
    , liz =
        { ani = Animator.init (GameCharacter Standing Right)
        , x = 0
        , y = 50
        , vx = 0
        , vy = 0
        }
    , window = { width = 800, height = 500 }
    }


type Action
    = Running
    | Walking
    | Standing
    | Ducking
    | Jumping


type Direction
    = Left
    | Right


updateGame : Model -> Float -> Model
updateGame model _ =
    let
        liz =
            model.liz

        arrows =
            Keyboard.Arrows.arrows model.pressedKeys

        currentLizChar =
            Animator.current model.liz.ani

        newLizChar =
            if arrows.x > 0 then
                GameCharacter Standing Left

            else
                GameCharacter Standing Right

        updatedLizAni =
            if currentLizChar == newLizChar then
                model.liz.ani

            else
                model.liz.ani
                    |> Animator.go Animator.immediately
                        newLizChar

        updatedLizGo =
            { liz
                | ani = updatedLizAni
                , x = liz.x + toFloat arrows.x
                , y = liz.y + toFloat arrows.y
            }
    in
    --model.currentSpeed + arrows.x
    { model
        | liz = updatedLizGo
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TriggerBurst ->
            let
                ( x, y ) =
                    model.mouse
            in
            ( { model | system = System.burst (Random.list 100 (particleAt x y)) model.system }
            , Cmd.none
            )

        MouseMove x y ->
            ( { model | mouse = ( x, y ) }
            , Cmd.none
            )

        ParticleMsg particleMsg ->
            ( { model | system = System.update particleMsg model.system }
            , Cmd.none
            )

        Tick newTime ->
            ( model |> Animator.update newTime animator
            , Cmd.none
            )

        Frame dt ->
            ( updateGame model dt
            , Cmd.none
            )

        KeyMsg keyMsg ->
            ( model
                |> (\m -> { m | pressedKeys = Keyboard.update keyMsg m.pressedKeys })
            , Cmd.none
            )



-- views


view : Model -> Html msg
view model =
    let
        ( mouseX, mouseY ) =
            model.mouse
    in
    Html.main_
        []
        [ System.view viewConfetti
            [ style "width" "100%"
            , style "height" "98vh"
            , style "z-index" "1"
            , style "position" "relative"
            , style "cursor" "none"
            ]
            model.system
        , Html.img
            [ --Attrs.src "tada.png"
              Attrs.width 64
            , Attrs.height 64

            --   , Attrs.alt "\"tada\" emoji from Mutant Standard"
            , style "position" "absolute"
            , style "left" (String.fromFloat (mouseX - 20) ++ "px")
            , style "top" (String.fromFloat (mouseY - 30) ++ "px")
            , style "user-select" "none"
            , style "cursor" "none"
            , style "z-index" "0"
            ]
            []
        , Html.div
            (positioner model model.liz)
            [ viewSprite <| handleLiz model ]
        ]

positioner : Model -> GameObject -> List (Html.Attribute msg)
positioner model go  = 
    [Attrs.class "positioner"
    , Attrs.style "position" "absolute"
    , Attrs.style "top" (String.fromFloat ((toFloat model.window.height / 2) - go.y) ++ "px")
    , Attrs.style "left" (String.fromFloat go.x ++ "px")]


handleLiz : Model -> Box
handleLiz model =
    Animator.step model.liz.ani <|
        \(GameCharacter action direction) ->
            let
                frame mySprite =
                    case direction of
                        Left ->
                            Animator.frame mySprite

                        Right ->
                            Animator.frame { mySprite | flipX = True }
            in
            case action of
                _ ->
                    --frame sprite.lizard.stand2
                    Animator.framesWith
                        { transition = frame sprite.lizard.stand1
                        , resting =
                            Animator.cycle
                                (Animator.fps 5)
                                [ frame sprite.lizard.stand2
                                , frame sprite.lizard.stand1
                                ]
                        }


animator : Animator.Animator Model
animator =
    Animator.animator
        -- we tell the animator how to get the checked timeline using .checked
        -- and we tell the animator how to update that timeline with updateChecked
        |> Animator.watching (\m -> m.liz.ani)
            (\lizani m ->
                let
                    liz =
                        m.liz
                in
                { m
                    | liz =
                        { liz
                            | ani = lizani
                        }
                }
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ System.sub [] ParticleMsg model.system
        , Browser.Events.onClick (Decode.succeed TriggerBurst)
        , Browser.Events.onMouseMove
            (Decode.map2 MouseMove
                (Decode.field "clientX" Decode.float)
                (Decode.field "clientY" Decode.float)
            )
        , Browser.Events.onAnimationFrameDelta Frame
        , Sub.map KeyMsg Keyboard.subscriptions
        , animator
            |> Animator.toSubscription Tick model
        ]


main : Program () Model Msg
main =
    Browser.element
        { init =
            \_ ->
                ( init
                , Cmd.none
                )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


stylesheet : Html msg
stylesheet =
    Html.node "style"
        []
        [ Html.text """@import url('https://fonts.googleapis.com/css?family=Roboto&display=swap');
body, html {
    margin: 0;
    padding:0;
    border:0;
    display:block;
    position: relative;
    width: 100%;
    height: 100%;
}
.pixel-art {
    image-rendering: pixelated;
    image-rendering: -moz-crisp-edges;
    image-rendering: crisp-edges;
}
"""
        ]

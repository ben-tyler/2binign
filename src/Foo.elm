module Foo exposing (..)



gcd a b = 
    if b == 0 then 
        a
    else 
        gcd b (remainderBy a b)

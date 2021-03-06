module Products.Edit exposing (..)

import Html exposing (..)
import Html.App
import Api.Models exposing (Product)
import Products.Form
import Products.Messages exposing (Msg(..))
import Products.Models exposing (ProductData)


view : Product -> ProductData -> Html Msg
view product model =
    div []
        [ h1 [] [ text <| "Editing Product - " ++ product.name ]
        , Products.Form.view
            { form = model.productForm
            , products = model.products
            , errors = model.formErrors
            , categories = model.categories
            }
            |> Html.App.map FormMessage
        ]

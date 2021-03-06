module Update exposing (..)

import Api.Models exposing (initialCategory, initialProduct)
import Categories.Models exposing (makeCategoryData)
import Categories.Update
import Messages exposing (Msg(..))
import Models exposing (Model, UIState)
import NavBar
import Products.Models exposing (makeProductData)
import Products.Update
import Routing exposing (Route(..))


updateUI : Route -> UIState -> UIState
updateUI route ui =
    case route of
        CategoryAddRoute ->
            let
                categories =
                    ui.categories

                updated =
                    { categories | categoryForm = initialCategory }
            in
                { ui | categories = updated }

        ProductAddRoute ->
            let
                products =
                    ui.products

                updated =
                    { products | productForm = initialProduct }
            in
                { ui | products = updated }

        _ ->
            ui


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavBarMessage subMsg ->
            NavBar.update subMsg model
                |> (\( m, c ) -> ( m, Cmd.map NavBarMessage c ))

        CategoriesMsg subMsg ->
            let
                ( updatedModel, cmd ) =
                    makeCategoryData model
                        |> Categories.Update.update subMsg

                categoryUI =
                    { categoryForm = updatedModel.categoryForm
                    , formErrors = updatedModel.formErrors
                    }

                ui =
                    model.uiState

                updatedUI =
                    { ui | categories = categoryUI }
            in
                ( { model
                    | categories = updatedModel.categories
                    , products = updatedModel.products
                    , uiState = updatedUI
                  }
                , Cmd.map CategoriesMsg cmd
                )

        ProductsMsg subMsg ->
            let
                ( updatedModel, cmd ) =
                    makeProductData model
                        |> Products.Update.update subMsg

                productsUI =
                    { showSKUs = updatedModel.showSKUs
                    , productForm = updatedModel.productForm
                    , formErrors = updatedModel.formErrors
                    }

                ui =
                    model.uiState

                updatedUI =
                    { ui | products = productsUI }
            in
                ( { model
                    | products = updatedModel.products
                    , productVariants = updatedModel.productVariants
                    , categories = updatedModel.categories
                    , uiState = updatedUI
                  }
                , Cmd.map ProductsMsg cmd
                )

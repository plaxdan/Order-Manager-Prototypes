module Categories.Models where

import Data.List (List)

import Api.Models (Category, Product)
import Model (class SubModel)


data CategoryData = CategoryData
    { categories :: List Category
    , products :: List Product
    }


instance submodelCategoryData :: SubModel CategoryData where
    updateModel model (CategoryData { categories, products }) =
        model { categories = categories, products = products }
    fromModel { categories, products } =
        CategoryData { categories, products }
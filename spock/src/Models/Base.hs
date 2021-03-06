{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
module Models.Base where

import Control.Monad                (mzero)
import Data.Aeson                   ( FromJSON(..), (.:), Value(..), ToJSON(..)
                                    , (.=), object)
import Data.Aeson.Types             (emptyObject)
import Data.Proxy                   (Proxy(..))
import Database.Persist
import Database.Persist.TH
import qualified Data.Text     as T

import Types


share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Category json
    name T.Text
    description T.Text default=''
    parent CategoryId Maybe
    UniqueCategory name
    deriving Show

Product json
    name T.Text
    description T.Text
    category CategoryId
    isOrganic Bool
    isHeirloom Bool
    isSouthEast Bool
    isActive Bool default=1
    UniqueProduct name
    deriving Show

ProductVariant json
    product ProductId
    sku T.Text
    weight Rational
    price Rational
    UniqueVariant sku
    deriving Show
|]


class Named a where
        name :: Proxy a -> T.Text

instance Named Category where name _ = "category"
instance Named Product where name _ = "product"
instance Named ProductVariant where name _ = "productVariant"
instance Named a => Named (Entity a) where
        name _ = name (Proxy :: Proxy a)

data JSONList a = JSONList [a]
instance (FromJSON a, Named a) => FromJSON (JSONList a) where
        parseJSON (Object o) = do
            named <- o .: name (Proxy :: Proxy a) >>= parseJSON
            return $ JSONList [named]
        parseJSON _          = mzero
instance (ToJSON a, Named a) => ToJSON (JSONList a) where
        toJSON (JSONList []) = emptyObject
        toJSON (JSONList l)  = object
            [name (Proxy :: Proxy a) .= map toJSON l]

data JSONObject a = JSONObject a
instance (FromJSON a, Named a) => FromJSON (JSONObject a) where
        parseJSON (Object o) = do
            named <- o .: name (Proxy :: Proxy a) >>= parseJSON
            return $ JSONObject named
        parseJSON _          = mzero
instance (ToJSON a, Named a) => ToJSON (JSONObject a) where
        toJSON (JSONObject a)  = object
            [name (Proxy :: Proxy a) .= toJSON a]


class Sideload a  where
        sideloads :: [Key a] -> OMRoute ctx m Value

instance Sideload Product where
        sideloads productIds = do
            variants <- runSQL $ selectList [ProductVariantProduct <-. productIds]
                                            [Asc ProductVariantSku]
            return . toJSON $ JSONList variants
instance Sideload Category where
        sideloads categoryIds = do
            products <- runSQL $ selectList [ProductCategory <-. categoryIds]
                                            [Asc ProductName]
            return . toJSON $ JSONList products

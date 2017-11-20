{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}

module Package where

import Data.List
import Data.Maybe
import Data.Repo
import Control.Lens.TH
import GHC.Generics
import Data.Aeson

data Package = Package { _github       :: Maybe String
                       , _dependencies :: [String]
                       , _name         :: String
                       , _repo         :: Maybe Repo
                       } deriving (Eq, Generic, Show)

makeLenses ''Package

instance ToJSON Package
instance FromJSON Package

hasGithub = isJust . _github

isGithub = ("github.com" `isSubsequenceOf`)

toPackageName = drop (length "http://hackage.haskell.org/package/")

dropGithub = drop 2. dropWhile (/= 'm')

toPackage [] = error "All package inputs should be non-empty"
toPackage x  | isGithub . head $ x = Package (Just . dropGithub . head $ x) (map (drop (length "/package/")) . init . tail $ x) (toPackageName $ last x) Nothing
             | otherwise           = Package (Nothing                     ) (map (drop (length "/package/")) . init        $ x) (toPackageName $ last x) Nothing

parsePackages :: String -> [Package]
parsePackages = map (toPackage . filter (not . null)) . groupBy (const $ not . null) . lines



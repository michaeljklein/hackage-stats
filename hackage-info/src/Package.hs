{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}

module Package where

import Data.List
import Data.Maybe
import Data.Repo
import Control.Lens.TH
import GHC.Generics
import Data.Aeson


-- | A single hackage package
data Package = Package { _github       :: Maybe String -- ^ github url
                       , _dependencies :: [String]     -- ^ dependency list
                       , _name         :: String       -- ^ package name
                       , _repo         :: Maybe Repo   -- ^ package repository
                       } deriving (Eq, Generic, Show)

makeLenses ''Package

instance ToJSON Package
instance FromJSON Package

-- | Does the `Package` have a github url?
hasGithub :: Package -> Bool
hasGithub = isJust . _github

-- | Is the string a github link?
isGithub :: [Char] -> Bool
isGithub = ("github.com" `isSubsequenceOf`)

-- | Drop as many characters as there are in: @"http://hackage.haskell.org/package/"@
toPackageName :: [a] -> [a]
toPackageName = drop (length "http://hackage.haskell.org/package/")

dropGithub :: String -> String
dropGithub = drop 2 . dropWhile (/= 'm')

toPackage :: [String] -> Package
toPackage [] = error "All package inputs should be non-empty"
toPackage x  | isGithub . head $ x = Package (Just . dropGithub . head $ x) (map (drop (length "/package/")) . init . tail $ x) (toPackageName $ last x) Nothing
             | otherwise           = Package (Nothing                     ) (map (drop (length "/package/")) . init        $ x) (toPackageName $ last x) Nothing

parsePackages :: String -> [Package]
parsePackages = map (toPackage . filter (not . null)) . groupBy (const $ not . null) . lines


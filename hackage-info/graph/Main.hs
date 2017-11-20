{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import System.Environment
import System.IO
import Control.Monad
import Data.List
import Data.Maybe
import Package
import Process
import Mathematica
import qualified Data.Text as T
import Data.Repo
import Control.Lens
import Parse
import Data.Attoparsec.Text (parseOnly)
import qualified Data.ByteString.Lazy as B
import Data.Aeson
import qualified Data.Map.Lazy as M
import Data.Tuple (swap)
import Data.Ratio

-- Maybe [Package]
-- M.Map Int B.ByteString

data WeightedEdge a = Wedge !Int a !Int

instance Functor WeightedEdge where
  fmap f ~(Wedge x w y) = Wedge x (f w) y

nameMap :: [Package] -> M.Map Int String
nameMap = foldr ($!) M.empty . map (uncurry M.insert) . zip [0..] . map _name

mapSwap :: Ord a => M.Map k a -> M.Map a k
mapSwap = M.fromList . map swap . M.toAscList

packageSizedEdges :: M.Map String Int -> Package -> [WeightedEdge Integer]
packageSizedEdges m p = map (Wedge (m M.! p ^. name) s) . map (m M.!) $ p ^. dependencies
  where
    s = maybe 0 id $ (p ^. repo) >>= (^. size)

sizedEdges :: M.Map String Int -> [Package] -> [WeightedEdge Integer]
sizedEdges m ps = ps >>= packageSizedEdges m

hstep x = if x < 0
             then 0
             else 1

-- | The 50th biggest has size 7517
top50 = fmap $ hstep . subtract 7517

toDouble :: Integer -> Double
toDouble = fromRational . (% 1)

-- "nodedef>name VARCHAR,label VARCHAR"
nodeLabels :: [Package] -> [(String, String, String)]
nodeLabels ps = map nodeLabel ps
  where
    nodeLabel p | isNothing $ p ^. repo                     = namef "" "0.0"
                | isNothing $ fromJust (p ^. repo) ^. size  = namef "" "0.0"
                | (== Just 0) $ fromJust (p ^. repo) ^. size = namef "" "0.0"
                | otherwise                                 = namef (p ^. name) $ show . toDouble . hstep . subtract 7517 . fromJust $ p ^. repo ^. size
      where
        namef = (p ^. name,,)


showe :: M.Map Int String -> WeightedEdge Integer -> (String, String, String)
showe _ (Wedge x 0 y) = (show x, show . toDouble $ 0, show y)
showe m (Wedge x w y) = (show $ m M.! x, show . toDouble $ 0, show $ m M.! y)


main :: IO ()
main = do
  args <- getArgs
  when (null args) $ putStrLn "Input arg should be .json file"
  packages <- liftM fromJust . liftM (\(x :: B.ByteString) -> (decode x) :: Maybe [Package]) . B.readFile . head $ args
  let namemap = nameMap packages
  let valmap  = mapSwap namemap
  let sedges  = map top50 . sizedEdges valmap $ packages
  (mapM_ print :: [WeightedEdge Integer] -> IO ()) sedges





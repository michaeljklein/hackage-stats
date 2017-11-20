{-# LANGUAGE TupleSections #-}

module Mathematica where

import Package

-- | (a, b) means the arc: a -> b
packageToArcs :: Package -> [(String, String)]
packageToArcs p = map (_name p,) $ _dependencies p

toMathematicaArcs :: Package -> [String]
toMathematicaArcs p = map convertOne . packageToArcs $ p
  where
    convertOne ~(x, y) = "DirectedEdge[" ++ show x ++ ", " ++ show y ++ "]"

toMathematicaList xs = (init . init $ "{" ++ concatMap (++ ", ") xs) ++ "}"

toMathematicaGraph :: [Package] -> String
toMathematicaGraph = ("Graph["++) . (++"]") . toMathematicaList . concatMap toMathematicaArcs

toCSV :: [Package] -> String
toCSV ps = unlines . map convertOne . concatMap packageToArcs $ ps
  where
    convertOne ~(x,y) = show x ++ ";" ++ show y


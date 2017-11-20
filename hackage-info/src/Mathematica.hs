{-# LANGUAGE TupleSections #-}

module Mathematica where

import Package

-- | (a, b) means the arc: a -> b
packageToArcs :: Package -> [(String, String)]
packageToArcs p = map (_name p,) $ _dependencies p

-- | Convert a package to a list of directed edges: @DirectedEdge@
toMathematicaArcs :: Package -> [String]
toMathematicaArcs p = map convertOne . packageToArcs $ p
  where
    convertOne ~(x, y) = "DirectedEdge[" ++ show x ++ ", " ++ show y ++ "]"

-- | Convert a foldable list of strings into a Mathematica list (as a string)
toMathematicaList :: Foldable t => t String -> String
toMathematicaList xs = (init . init $ "{" ++ concatMap (++ ", ") xs) ++ "}"

-- | Convert a list of `Package`s into a single Mathematica @Graph@ (source)
toMathematicaGraph :: [Package] -> String
toMathematicaGraph = ("Graph["++) . (++"]") . toMathematicaList . concatMap toMathematicaArcs

-- | Convert a list of `Package`s into a single @csv@ `String`
toCSV :: [Package] -> String
toCSV ps = unlines . map convertOne . concatMap packageToArcs $ ps
  where
    convertOne ~(x,y) = show x ++ ";" ++ show y


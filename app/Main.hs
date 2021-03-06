
module Main where

import Control.Lens
import Control.Monad
import Data.Aeson
import Data.Attoparsec.Text (parseOnly)
import Data.Maybe
import Data.Repo
import Mathematica
import Package
import Parse
import Process
import System.Environment
import qualified Data.ByteString.Lazy as B
import qualified Data.Text as T


fromBool :: Num a => Bool -> a
fromBool True = 1
fromBool _    = 0

numberWithGithub :: [Package] -> Integer
numberWithGithub = sum . map (fromBool . hasGithub)

maybeParse :: String -> Maybe Repo
maybeParse s = case parseOnly parseLines . T.pack $ s of
                 Left  _    -> Nothing
                 ~(Right r) -> Just r

addRepo :: String -> String -> (Integer, Package) -> IO Package
addRepo u p (i, pck) = case pck ^. github of
                        Nothing -> return pck
                        Just g  -> do
                          when (mod i 1000 == 0) $ getLine >> return () -- every thousand, get user input so that api rates not exceeded
                          putStrLn $ show i ++ ": " ++ show (pck ^. github)
                          curled <- curl u p g
                          print curled
                          return $ pck & repo .~ (curled >>= maybeParse)

main :: IO ()
main = do
  args <- getArgs
  when (null args) $ putStrLn "args must be: user pass [package number to start at] [input filename]"
  let user     =        args !! 0
  let pass     =        args !! 1
  let toDrop   = read $ args !! 2
  let fileName =        args !! 3
  contents <- readFile fileName
  let parsed = drop toDrop . zip [0..] . parsePackages $ contents
  putStrLn $ "Number of packages: " ++ show (length parsed)
  putStrLn $ "Number with Github: " ++ show (length . filter (isJust . _github . snd) $ parsed)
  getLine >> return ()
  writeFile "mathematica_graph.txt" . toMathematicaGraph . map snd $ parsed
  writeFile "graph.csv" . toCSV . map snd $ parsed
  packs <- mapM (addRepo user pass) parsed
  B.writeFile "stats.json" $ encode packs
  return ()


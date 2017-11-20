{-# LANGUAGE OverloadedStrings #-}

module Parse where

import Control.Lens.Operators
import Control.Applicative
import Data.Attoparsec.Text
import qualified Data.Text as T
import Data.Repo
import Control.Lens.Setter
import Data.Text.Read

dropLine :: Parser ()
dropLine = skipWhile (/= '\n') >> skip (== '\n')

value :: ASetter Repo Repo a1 a -> T.Text -> Parser a -> Parser Repo
value setter s p = do
  string s
  val <- p
  dropLine
  return $ (blankRepo & setter .~ val)

date :: Parser (Maybe Date)
date = do
  char '\"'
  yearStr <- count 4 digit
  char '-'
  monthStr <- count 2 digit
  char '-'
  dayStr <- count 2 digit
  return . Just $ Date (read yearStr) (read monthStr) (read dayStr)

integer :: Parser (Maybe Integer)
integer = many1 digit >>= return . Just . read

str :: Parser (Maybe T.Text)
str = do
  char '\"'
  t <- many1 $ notChar '\"'
  char '\"'
  return . Just . T.pack $ t


parseCreated :: Parser Repo
parseCreated = value created_at "  \"created_at\": " date

parseUpdated :: Parser Repo
parseUpdated = value updated_at "  \"updated_at\": " date

parsePushed :: Parser Repo
parsePushed = value pushed_at "  \"pushed_at\": " date

parseSizeParser :: Parser Repo
parseSizeParser = value size "  \"size\": " integer

parseStargazers :: Parser Repo
parseStargazers = value stargazers_count "  \"stargazers_count\": " integer

parseWatchers_count :: Parser Repo
parseWatchers_count = value watchers_count "  \"watchers_count\": " integer

parseLang :: Parser Repo
parseLang = value language "  \"language\": " str

parseForkCount :: Parser Repo
parseForkCount = value forks_count "  \"forks_count\": " integer

parseOpenIssues :: Parser Repo
parseOpenIssues = value open_issues_count "  \"open_issues_count\": " integer

parseWatchers :: Parser Repo
parseWatchers = value watchers "  \"watchers\": " integer

parseNetworkCount :: Parser Repo
parseNetworkCount = value network_count "  \"network_count\": " integer

parseSubscribers :: Parser Repo
parseSubscribers = value subscribers_count "  \"subscribers_count\": " integer

parseLine :: Parser Repo
parseLine = foldr1 (<|>) [ parseCreated
                         , parseUpdated
                         , parsePushed
                         , parseSizeParser
                         , parseStargazers
                         , parseWatchers_count
                         , parseLang
                         , parseForkCount
                         , parseOpenIssues
                         , parseWatchers
                         , parseNetworkCount
                         , parseSubscribers
                         , fmap (const blankRepo) dropLine
                         ]

parseLines = fmap mconcat $ many1 parseLine



{-# LANGUAGE OverloadedStrings #-}

module Parse where

import Control.Applicative
import Control.Lens.Operators
import Control.Lens.Setter
import Data.Attoparsec.Text
import Data.Repo
import qualified Data.Text as T


-- | Parse (and toss) the rest of the current line
dropLine :: Parser ()
dropLine = skipWhile (/= '\n') >> skip (== '\n')

-- | Parse a value, given a setter, header string, and body parser
value :: ASetter Repo Repo t a -> T.Text -> Parser a -> Parser Repo
value setter s p = do
  _   <- string s
  val <- p
  dropLine
  return $ (blankRepo & setter .~ val)

-- | Parse a `Date`
date :: Parser (Maybe Date)
date = do
  _        <- char '\"'
  yearStr  <- count 4 digit
  _        <- char '-'
  monthStr <- count 2 digit
  _        <- char '-'
  dayStr   <- count 2 digit
  return . Just $ Date (read yearStr) (read monthStr) (read dayStr)

-- | Parse an `Integer`
integer :: Parser (Maybe Integer)
integer = many1 digit >>= return . Just . read

-- | Parse a quoted string
str :: Parser (Maybe T.Text)
str = do
  _ <- char '\"'
  t <- many1 $ notChar '\"'
  _ <- char '\"'
  return . Just . T.pack $ t


-- | @`parseCreated` = `value` created_at "  \"created_at\": " date@
parseCreated :: Parser Repo
parseCreated = value created_at "  \"created_at\": " date

-- | @`parseUpdated` = `value` updated_at "  \"updated_at\": " date@
parseUpdated :: Parser Repo
parseUpdated = value updated_at "  \"updated_at\": " date

-- | @`parsePushed` = `value` pushed_at "  \"pushed_at\": " date@
parsePushed :: Parser Repo
parsePushed = value pushed_at "  \"pushed_at\": " date

-- | @`parseSizeParser` = `value` size "  \"size\": " integer@
parseSizeParser :: Parser Repo
parseSizeParser = value size "  \"size\": " integer

-- | @`parseStargazers` = `value` stargazers_count "  \"stargazers_count\": " integer@
parseStargazers :: Parser Repo
parseStargazers = value stargazers_count "  \"stargazers_count\": " integer

-- | @`parseWatchers_count` = `value` watchers_count "  \"watchers_count\": " integer@
parseWatchers_count :: Parser Repo
parseWatchers_count = value watchers_count "  \"watchers_count\": " integer

-- | @`parseLang` = `value` language "  \"language\": " str@
parseLang :: Parser Repo
parseLang = value language "  \"language\": " str

-- | @`parseForkCount` = `value` forks_count "  \"forks_count\": " integer@
parseForkCount :: Parser Repo
parseForkCount = value forks_count "  \"forks_count\": " integer

-- | @`parseOpenIssues` = `value` open_issues_count "  \"open_issues_count\": " integer@
parseOpenIssues :: Parser Repo
parseOpenIssues = value open_issues_count "  \"open_issues_count\": " integer

-- | @`parseWatchers` = `value` watchers "  \"watchers\": " integer@
parseWatchers :: Parser Repo
parseWatchers = value watchers "  \"watchers\": " integer

-- | @`parseNetworkCount` = `value` network_count "  \"network_count\": " integer@
parseNetworkCount :: Parser Repo
parseNetworkCount = value network_count "  \"network_count\": " integer

-- | @`parseSubscribers` = `value` subscribers_count "  \"subscribers_count\": " integer@
parseSubscribers :: Parser Repo
parseSubscribers = value subscribers_count "  \"subscribers_count\": " integer

-- | Parse an entire line into a `Repo`
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

-- | Parse a bunch of lines into `Repo`s
parseLines :: Parser Repo
parseLines = fmap mconcat $ many1 parseLine



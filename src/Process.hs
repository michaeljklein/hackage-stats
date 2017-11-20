module Process where

import Control.Monad
import Network.Curl
import Network.Curl.Code
import Network.Curl.Opts
import System.Exit
import System.Process

-- | If success, `Just`, else `Nothing`
success :: ExitCode -> a -> Maybe a
success ExitSuccess x = Just x
success _           _ = Nothing

-- | Given a filepath, list of arguements, stdin string, get stdout or nothing on failure
readProc :: FilePath -> [String] -> String -> IO (Maybe String)
readProc c a i = do
  ~(e, o, r) <- readProcessWithExitCode c a i
  when (not . null $ r) (putStrLn r)
  return $ success e o

-- | Curl: user, password, repo name
curl :: String -> String -> String -> IO (Maybe String)
curl u p s = readProc "/usr/bin/curl" ["-u", u ++ ":" ++ p, "https://api.github.com/repos/" ++ s] []

-- | Collect user, pass as `CurlOption`s
splitUserPass :: String -> String -> [CurlOption]
splitUserPass u p = [CurlUserName u, CurlUserPassword p]


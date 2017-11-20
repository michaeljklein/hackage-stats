module Process where

import Control.Monad
import Network.Curl
import Network.Curl.Code
import Network.Curl.Opts
import System.Exit
import System.Process

success :: ExitCode -> a -> Maybe a
success ExitSuccess x = Just x
success _           _ = Nothing

readProc :: FilePath -> [String] -> String -> IO (Maybe String)
readProc c a i = do
  ~(e, o, r) <- readProcessWithExitCode c a i
  when (not . null $ r) (putStrLn r)
  return $ success e o

-- readProc' c a i = do
--   ~(e, o, _) <- readProcessWithExitCode c a i
--   return $ trace' $ success e o


-- trace' x = trace (show x) x

curl :: String -> String -> String -> IO (Maybe String)
curl u p s = readProc "/usr/bin/curl" ["-u", u ++ ":" ++ p, "https://api.github.com/repos/" ++ s] []

splitUserPass :: String -> String -> [CurlOption]
splitUserPass u p = [CurlUserName u, CurlUserPassword p]

-- curl :: String -> String -> String -> IO (Maybe String)
-- curl u p s = do
--   result <- curlGetString ("https://api.github.com/repos/"++s) $ splitUserPass u p
--   case result of
--     (CurlOK, got) -> return . Just $ got
--     (e     , got) -> do
--       putStrLn $ "Exited with: " ++ show e ++ ", " ++ got
--       return Nothing

module Paths_hackage_info (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/michaelklein/Coding/scratch/s6/basic/.stack-work/install/x86_64-osx/lts-5.14/7.10.3/bin"
libdir     = "/Users/michaelklein/Coding/scratch/s6/basic/.stack-work/install/x86_64-osx/lts-5.14/7.10.3/lib/x86_64-osx-ghc-7.10.3/hackage-info-0.1.0.0-8AzqFXcXsXI1zCeqNUsPcm"
datadir    = "/Users/michaelklein/Coding/scratch/s6/basic/.stack-work/install/x86_64-osx/lts-5.14/7.10.3/share/x86_64-osx-ghc-7.10.3/hackage-info-0.1.0.0"
libexecdir = "/Users/michaelklein/Coding/scratch/s6/basic/.stack-work/install/x86_64-osx/lts-5.14/7.10.3/libexec"
sysconfdir = "/Users/michaelklein/Coding/scratch/s6/basic/.stack-work/install/x86_64-osx/lts-5.14/7.10.3/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "hackage_info_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "hackage_info_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "hackage_info_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "hackage_info_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "hackage_info_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)

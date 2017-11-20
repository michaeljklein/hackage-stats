{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}

module Data.Repo where

import Control.Applicative
import Control.Lens.TH
import Data.Aeson
import GHC.Generics
import qualified Data.Text as T

data Date = Date { year  :: Integer
                 , month :: Integer
                 , day   :: Integer
                 } deriving (Eq, Generic)


instance Show Date where
  show (Date y m d) = concat [show y, "-", show m, "-", show d]


instance ToJSON Date
instance FromJSON Date


data Repo = Repo { _created_at        :: Maybe Date
                 , _updated_at        :: Maybe Date
                 , _pushed_at         :: Maybe Date
                 , _size              :: Maybe Integer
                 , _stargazers_count  :: Maybe Integer
                 , _watchers_count    :: Maybe Integer
                 , _language          :: Maybe T.Text
                 , _forks_count       :: Maybe Integer
                 , _open_issues_count :: Maybe Integer
                 , _watchers          :: Maybe Integer
                 , _network_count     :: Maybe Integer
                 , _subscribers_count :: Maybe Integer
                 } deriving (Eq, Generic, Show)

blankRepo = Repo n n n n n n n n n n n n
  where
    n = Nothing

instance Monoid Repo where
  mempty = blankRepo
  mappend r1 r2 =  Repo { _created_at        = _created_at r1 <|> _created_at r2
                        , _updated_at        = _updated_at r1 <|> _updated_at r2
                        , _pushed_at         = _pushed_at r1 <|> _pushed_at r2
                        , _size              = _size r1 <|> _size r2
                        , _stargazers_count  = _stargazers_count r1 <|> _stargazers_count r2
                        , _watchers_count    = _watchers_count r1 <|> _watchers_count r2
                        , _language          = _language r1 <|> _language r2
                        , _forks_count       = _forks_count r1 <|> _forks_count r2
                        , _open_issues_count = _open_issues_count r1 <|> _open_issues_count r2
                        , _watchers          = _watchers r1 <|> _watchers r2
                        , _network_count     = _network_count r1 <|> _network_count r2
                        , _subscribers_count = _subscribers_count r1 <|> _subscribers_count r2
                        }

makeLenses ''Repo

instance ToJSON Repo
instance FromJSON Repo


{-# LANGUAGE OverloadedStrings #-}

module Utils.Render
  ( compareToNow
  , doubleToInt
  , translateStatus
  ) where

import Data.Text              (Text)
import Data.Time              (UTCTime)
import Model.Types.Assignment (Status(..))


------------------------------------------------------------------------------
-- | 
translateStatus :: Status -> Text
translateStatus Mandatory = "Pflicht"
translateStatus Optional  = "Zusätzlich"


------------------------------------------------------------------------------
-- | 
compareToNow :: UTCTime -> Maybe UTCTime -> Maybe UTCTime -> String
compareToNow _   Nothing      _          = "offen"
compareToNow _   _            Nothing    = "offen"
compareToNow now (Just begin) (Just end)
    | now < begin = (show begin) ++ " - " ++ (show end)
    | now < end = "noch bis " ++ (show end)
    | otherwise = "vorbei seit " ++ (show end)


------------------------------------------------------------------------------
-- | 
doubleToInt :: Double -> Int
doubleToInt = read . takeWhile ((/=) '.') . show

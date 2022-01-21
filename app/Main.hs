{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Control.Concurrent (getNumCapabilities)
import qualified Control.Concurrent.Async as Async
import Control.DeepSeq (NFData, deepseq)
import qualified Control.Scheduler as Scheduler
import Data.Foldable (Foldable (foldl'))
import Data.List (transpose)
import Data.List.Split (chunksOf)
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import System.Environment (getArgs)
import System.Exit (exitFailure)

{-
a function that does some meaningless manipulation
of text objects, to mimic the original program regarding
runtime and memory profile
-}
dummyFunc :: Text -> Text
dummyFunc hyph =
    let lsFoo = replicate 600 hyph
     in Text.takeEnd 100 $
            foldl' (\strRes str -> Text.head str `Text.cons` strRes) "" lsFoo

fmapForce :: NFData b => (a -> b) -> [a] -> [b]
fmapForce _ [] = []
fmapForce f (x : xs) =
    let y = f x
        ys = y `deepseq` fmapForce f xs
     in y : ys

exitUsage :: IO a
exitUsage = do
    putStrLn "Usage: ./ghc-concurrency-speedup -a|-s hyphenated.txt"
    exitFailure

main :: IO ()
main = do
    -- run: ./ghc-concurrency-speedup -a|-s hyphenated.txt
    args <- getArgs
    (concF, file) <- case args of
        [str, filename] ->
            (,filename) <$> case str of
                "-a" -> pure Async.mapConcurrently
                "-s" -> pure $ Scheduler.traverseConcurrently $ Scheduler.ParN 0
                _ -> exitUsage
        _ -> exitUsage

    nj <- getNumCapabilities
    ls <- Text.lines <$> Text.readFile file
    r <-
        if nj == 1
            then pure $ fmapForce dummyFunc ls
            else
                mconcat
                    <$> concF
                        (pure . fmapForce dummyFunc)
                        (transpose $ chunksOf (10 * nj) ls)
    putStrLn $ last r `seq` "done"

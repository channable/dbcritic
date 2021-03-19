module Main

import Control.IOExcept
import Data.IORef
import Dbcritic.Check
import Dbcritic.Check.IndexFkRef
import Dbcritic.Check.PrimaryKey
import Dbcritic.Check.TimeZone
import Dbcritic.Check.Timestamptz
import Dbcritic.Config
import Dbcritic.Libpq
import System

checks : List Check
checks = [ checkIndexFkRef, checkPrimaryKey, checkTimeZone, checkTimestamptz ]

main' : IOExcept String Int
main' = do

    config <- readConfig ".dbcriticrc"
    conn   <- pgConnect ""
    index  <- ioe_lift $ newIORef 0

    for_ checks $ \check => do
        allIssues <- inspect check conn
        let allSilences = getSilences config check
        let issues = filter (not . isSilenced allSilences) allIssues
        let unsilence = filter (not . silencesIssue allIssues) allSilences

        for_ issues $ \issue => do
            index' <- ioe_lift $ modifyIORef index (+ 1) *> readIORef index
            ioe_lift $ putStrLn (formatIssue index' check issue)

        for_ unsilence $ \silence => do
            index' <- ioe_lift $ modifyIORef index (+ 1) *> readIORef index
            ioe_lift $ putStrLn (formatSilence index' silence)

    count <- ioe_lift $ readIORef index
    pure $ if count > 0 then 1 else 0

main : IO ()
main = do
    result <- runIOExcept main'
    case result of
        Right n  => exit n
        Left err => do fPutStrLn stderr err
                       exit 2

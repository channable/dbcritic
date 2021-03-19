module Dbcritic.Config

import Control.IOExcept
import Dbcritic.Check
import Dbcritic.Interface

public export
record Silence where
    constructor MkSilence

    silenceCheck : String
    silenceIssue : List String

public export
record Config where
    constructor MkConfig

    ||| For a check any issue that matches the issue prefix will not be
    ||| reported. These issues are called silenced issues.
    silences : List Silence

export
getSilences : Config -> Check -> List Silence
getSilences config check =
    filter ((==) (identifier check) . silenceCheck)
        (silences config)

silences : Silence -> Issue -> Bool
silences silence issue =
    (silenceIssue silence) `isPrefixOf` (identifier issue)

export
isSilenced : List Silence -> Issue -> Bool
isSilenced allSilences issue = any (`silences` issue) allSilences

export
silencesIssue : List Issue -> Silence -> Bool
silencesIssue allIssues silence = any (silence `silences`) allIssues

export
formatSilence : Int -> Silence -> String
formatSilence index silence =
    formatMessage index description problems solutions
    where
    description = "Unneeded silence directive"
    problems = ["You may reintroduce the resolved issue."]
    solutions = ["Unsilence this issue or check by removing: ‘silence " ++
        unwords (silenceCheck silence :: silenceIssue silence) ++ "’."]

||| Parse configuration that was already read from a file.
||| See README.md for a description of the configuration file format.
export
parseConfig : String -> Either String Config
parseConfig = foldlM parseLine emptyConfig . map words . lines
    where

    emptyConfig : Config
    emptyConfig = MkConfig []

    parseLine : Config -> List String -> Either String Config

    -- Skip empty lines and comment lines.
    parseLine config []         = Right config
    parseLine config ("#" :: _) = Right config

    -- Parse silence directives.
    parseLine config ("silence" :: check :: issue) =
        let
            silence = MkSilence check issue
        in
            Right $ record { silences $= (silence ::) } config
    parseLine config ("silence" :: []) =
        Left "Empty silence directive"

    -- Anything else is an error.
    parseLine config (directive :: _) =
        Left ("Unknown directive: ‘" ++ directive ++ "’")

||| Read configuration from a file and then parse it.
||| See README.md for a description of the configuration file format.
export
readConfig : String -> IOExcept String Config
readConfig path = IOM $ do
    let context = path ++ ": "
    let handle  = either (Left . (context ++) . show) Right
    contents <- handle <$> readFile path
    pure $ contents >>= parseConfig

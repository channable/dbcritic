module Dbcritic.Check

import Control.IOExcept
import Dbcritic.Interface
import Dbcritic.Libpq

public export
record Issue where
    constructor MkIssue

    identifier    : List String
    description   : String
    problems      : List String
    solutions     : List String

    identifier_ne : NonEmpty identifier
    problems_ne   : NonEmpty problems
    solutions_ne  : NonEmpty solutions

public export
record Check where
    constructor MkCheck
    identifier : String
    help       : String
    inspect    : PgConnection -> IOExcept String (List Issue)

||| The qualified identifier of an issue incorporates both
||| the identifier of the check and the identifier of the issue.
qualified : Check -> Issue -> List String
qualified check issue = identifier check :: identifier issue

export
formatIssue : Int -> Check -> Issue -> String
formatIssue index check issue =
    formatMessage index (description issue) (problems issue) (solutions issue ++ [silenceIssue, silenceCheck])
    where
    silenceIssue = "Silence this issue: ‘silence " ++ unwords (qualified check issue) ++ "’."
    silenceCheck = "Silence this check: ‘silence " ++ identifier check ++ "’."

module Dbcritic.Check.TimeZone

import Control.IOExcept
import Data.Vect
import Dbcritic.Check
import Dbcritic.Libpq

export
issueLocaltime : Issue
issueLocaltime =
    let
        identifier  = [ "localtime" ]
        description = "The client receives timestamps in the time zone of the server."
        problems    = [ "Changing the server time zone causes the client to receive different timestamps." ]
        solutions   = [ "Set the ‘TimeZone’ configuration parameter to a concrete time zone, such as UTC." ]
    in
        MkIssue identifier description problems solutions IsNonEmpty IsNonEmpty IsNonEmpty

export
checkTimeZone : Check
checkTimeZone = MkCheck name help inspect
    where
    name = "time_zone"
    help = "Check that the ‘TimeZone’ parameter is set to a sensible value."

    inspect : PgConnection -> IOExcept String (List Issue)
    inspect conn = do
        res <- pgExecute conn """
            SHOW "TimeZone"
        """
        case pgCell res 0 0 of
            Just "localtime" => pure [issueLocaltime]
            Just _           => pure []
            Nothing          => ioe_fail "checkTimeZone: Bad result"

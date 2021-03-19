module Dbcritic.Check.Timestamptz

import Control.IOExcept
import Dbcritic.Check
import Dbcritic.Libpq

mkIssue : String -> String -> Issue
mkIssue table column =
    let
        qual        = table ++ "." ++ column
        identifier  = [ table, column ]
        description = "The column ‘" ++ qual ++ "’ stores timestamps in an ambiguous format."
        problems    = [ "You cannot tell when the event happened without more information."
                      , "Timestamps in different time zones may accumulate in the database." ]
        solutions   = [ "Change the type of the column ‘" ++ qual ++ "’ to ‘timestamptz’." ]
    in
        MkIssue identifier description problems solutions IsNonEmpty IsNonEmpty IsNonEmpty

export
checkTimestamptz : Check
checkTimestamptz = MkCheck name help inspect
    where
    name = "timestamptz"
    help = "Check that columns are of the type ‘timestamptz’ rather than of the type ‘timestamp’."

    inspectRow : List (Maybe String) -> IOExcept String Issue
    inspectRow [Just table, Just column] = pure (mkIssue table column)
    inspectRow _ = ioe_fail "checkTimestamptz: Bad result"

    inspect : PgConnection -> IOExcept String (List Issue)
    inspect conn = do
        res <- pgExecute conn """
            SELECT
                pg_class.relname,
                pg_attribute.attname
            FROM
                pg_attribute
                JOIN pg_class ON pg_class.oid = pg_attribute.attrelid
            WHERE
                pg_attribute.atttypid = 'timestamp' :: regtype AND
                pg_class.relnamespace <> regnamespace 'information_schema' AND
                pg_class.relnamespace <> regnamespace 'pg_catalog'
            ORDER BY
                pg_class.relname,
                pg_attribute.attname
        """
        traverse inspectRow (pgGrid res)

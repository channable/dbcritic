module Dbcritic.Check.PrimaryKey

import Control.IOExcept
import Dbcritic.Check
import Dbcritic.Libpq

mkIssue : String -> Issue
mkIssue table =
    let
        identifier  = [ table ]
        description = "The table ‘" ++ table ++ "’ is missing a primary key constraint."
        problems    = [ "Rows cannot be individually addressed when updating or deleting them."
                      , "Rows cannot be individually addressed by potential foreign keys."
                      , "Some tools expect tables to have primary keys to function properly." ]
        solutions   = [ "Create a primary key constraint on ‘" ++ table ++ "’." ]
    in
        MkIssue identifier description problems solutions IsNonEmpty IsNonEmpty IsNonEmpty

export
checkPrimaryKey : Check
checkPrimaryKey = MkCheck name help inspect
    where
    name = "primary_key"
    help = "Check that each table has a primary key constraint."

    inspectRow : List (Maybe String) -> IOExcept String Issue
    inspectRow [Just table] = pure (mkIssue table)
    inspectRow _ = ioe_fail "checkPrimaryKey: Bad result"

    inspect : PgConnection -> IOExcept String (List Issue)
    inspect conn = do
        res <- pgExecute conn """
            SELECT relname
            FROM   pg_class
            WHERE  relkind = 'r' AND
                   NOT EXISTS
                       ( SELECT
                         FROM   pg_constraint
                         WHERE  conrelid = pg_class.oid AND
                                contype  = 'p' ) AND
                   relnamespace <> regnamespace 'information_schema' AND
                   relnamespace <> regnamespace 'pg_catalog'
            ORDER BY relname ASC
        """
        traverse inspectRow (pgGrid res)

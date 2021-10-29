module Dbcritic.Check.PrimaryKeyType

import Control.IOExcept
import Dbcritic.Check
import Dbcritic.Libpq

mkIssue : String -> String -> Issue
mkIssue table column =
    let
        identifier  = [ table, column ]
        description = "The table ‘" ++ table ++ "’ primary key (" ++ column ++ ") is "
                      ++ "of type ‘integer’ instead of ‘bigint’."
        problems    = [ "PostgreSQL's integer type is 4 bytes. It is relatively easy to run out of values." ]
        solutions   = [ "Change the type of ‘" ++ table ++ "." ++ column ++ "’ to ‘bigint’, "
                      ++ "as well as its associated auto generating sequence if it exists." ]
    in
        MkIssue identifier description problems solutions IsNonEmpty IsNonEmpty IsNonEmpty

export
checkPrimaryKeyBigint : Check
checkPrimaryKeyBigint = MkCheck name help inspect
    where
    name = "primary_key_bigint"
    help = "Check that there are no tables with an integer primary key."

    inspectRow : List (Maybe String) -> IOExcept String Issue
    inspectRow [Just table, Just column] = pure (mkIssue table column)
    inspectRow _ = ioe_fail "checkPrimaryKeyBigint: Bad result"

    inspect : PgConnection -> IOExcept String (List Issue)
    inspect conn = do
        res <- pgExecute conn """
            SELECT
                kcu.table_name as table_name,
                kcu.column_name as column_name
            FROM information_schema.table_constraints tco
            JOIN information_schema.key_column_usage kcu
                ON kcu.constraint_name = tco.constraint_name
                AND kcu.constraint_schema = tco.constraint_schema
                AND kcu.constraint_name = tco.constraint_name
            JOIN information_schema.columns c
                ON c.table_name = kcu.table_name
                AND c.column_name = kcu.column_name
            WHERE tco.constraint_type = 'PRIMARY KEY'
            AND c.data_type = 'integer'
            ORDER BY table_name
        """
        traverse inspectRow (pgGrid res)

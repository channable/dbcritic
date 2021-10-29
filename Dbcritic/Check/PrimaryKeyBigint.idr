module Dbcritic.Check.PrimaryKeyType

import Control.IOExcept
import Dbcritic.Check
import Dbcritic.Libpq


formatTypeByteSize : String -> String
formatTypeByteSize type =
    case byteSizeOfType type of
        Nothing => "unknown"
        Just byteSize => show byteSize
    where
        byteSizeOfType : String -> Maybe Int
        byteSizeOfType "smallint" = Just 2
        byteSizeOfType "integer" = Just 4
        byteSizeOfType _ = Nothing

mkIssue : String -> String -> String -> String -> Issue
mkIssue schema table column column_type =
    let
        fullTable   = schema ++ "." ++ table
        identifier  = [ schema, table, column ]
        description = "The table ‘" ++ fullTable ++ "’ primary key (" ++ column ++ ") is "
                      ++ "of type ‘" ++ column_type ++ "’ instead of ‘bigint’."
        columnByteSize = formatTypeByteSize column_type
        problems    = [ "PostgreSQL's " ++ column_type ++ " type is " ++ columnByteSize
                      ++ " bytes. It is relatively easy to run out of values." ]
        solutions   = [ "Change the type of ‘" ++ fullTable ++ "." ++ column ++ "’ to ‘bigint’, "
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
    inspectRow [Just schema, Just table, Just column, Just column_type] =
                   pure (mkIssue schema table column column_type)
    inspectRow _ = ioe_fail "checkPrimaryKeyBigint: Bad result"

    inspect : PgConnection -> IOExcept String (List Issue)
    inspect conn = do
        res <- pgExecute conn """
            SELECT
                kcu.table_schema as schema_name,
                kcu.table_name as table_name,
                kcu.column_name as column_name,
                c.data_type as column_type
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
                ON kcu.constraint_name = tc.constraint_name
                AND kcu.constraint_schema = tc.constraint_schema
                AND kcu.constraint_name = tc.constraint_name
            JOIN information_schema.columns c
                ON c.table_schema = kcu.table_schema
                AND c.table_name = kcu.table_name
                AND c.column_name = kcu.column_name
            WHERE tc.constraint_type = 'PRIMARY KEY'
            AND c.data_type IN ('smallint', 'integer')
            ORDER BY schema_name, table_name
        """
        traverse inspectRow (pgGrid res)

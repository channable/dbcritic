module Dbcritic.Check.IndexFkRef

import Control.IOExcept
import Dbcritic.Check
import Dbcritic.Libpq

mkIssue : String -> String -> String -> Issue
mkIssue table fk cols =
    let
        qual        = table ++ "." ++ fk
        identifier  = [ table, fk ]
        description = "The foreign key constraint ‘" ++ qual ++ "’ is missing an index on its referencing side."
        problems    = [ "Updating rows in the referenced table causes a sequential scan on the referencing table."
                      , "Deleting rows from the referenced table causes a sequential scan on the referencing table." ]
        solutions   = [ "Create an index on ‘" ++ table ++ " (" ++ cols ++ ")’." ]
    in
        MkIssue identifier description problems solutions IsNonEmpty IsNonEmpty IsNonEmpty

export
checkIndexFkRef : Check
checkIndexFkRef = MkCheck name help inspect
    where
    name = "index_fk_ref"
    help = "Check that foreign key has an index on its referencing side."

    inspectRow : List (Maybe String) -> IOExcept String Issue
    inspectRow [Just table, Just fk, Just cols] = pure (mkIssue table fk cols)
    inspectRow _ = ioe_fail "checkIndexFkRef: Bad result"

    inspect : PgConnection -> IOExcept String (List Issue)
    inspect conn = do
        res <- pgExecute conn """
            SELECT
                pg_class.relname,
                pg_constraint.conname,
                (
                    SELECT string_agg(pg_attribute.attname, ', ')
                    FROM   pg_attribute
                    WHERE  pg_attribute.attrelid = pg_constraint.conrelid AND
                           ARRAY[pg_attribute.attnum] <@ pg_constraint.conkey
                )
            FROM
                pg_constraint
                JOIN pg_class ON pg_class.oid = pg_constraint.conrelid
            WHERE
                pg_constraint.contype = 'f' AND
                NOT EXISTS (
                    SELECT
                    FROM
                        pg_index
                    WHERE
                        pg_index.indrelid = pg_constraint.conrelid AND
                        ( CAST(pg_index.indkey AS text) || ' ' LIKE
                          array_to_string(pg_constraint.conkey, ' ') || ' %' )
                ) AND
                pg_constraint.connamespace <> regnamespace 'information_schema' AND
                pg_constraint.connamespace <> regnamespace 'pg_catalog'
            ORDER BY
                pg_class.relname,
                pg_constraint.conname
        """
        traverse inspectRow (pgGrid res)

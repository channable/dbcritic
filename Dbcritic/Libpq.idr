module Dbcritic.Libpq

import Control.IOExcept
import Data.Vect

%include C "libpq-fe.h"
%lib C "pq"

namespace raw
    connectdb : String -> IO Ptr
    connectdb = foreign FFI_C "PQconnectdb" (String -> IO Ptr)

    errorMessage : Ptr -> IO String
    errorMessage = foreign FFI_C "PQerrorMessage" (Ptr -> IO String)

    exec : Ptr -> String -> IO Ptr
    exec = foreign FFI_C "PQexec" (Ptr -> String -> IO Ptr)

    getisnull : Ptr -> Int -> Int -> IO Int
    getisnull = foreign FFI_C "PQgetisnull" (Ptr -> Int -> Int -> IO Int)

    getvalue : Ptr -> Int -> Int -> IO String
    getvalue = foreign FFI_C "PQgetvalue" (Ptr -> Int -> Int -> IO String)

    nfields : Ptr -> IO Int
    nfields = foreign FFI_C "PQnfields" (Ptr -> IO Int)

    ntuples : Ptr -> IO Int
    ntuples = foreign FFI_C "PQntuples" (Ptr -> IO Int)

    resultErrorMessage : Ptr -> IO String
    resultErrorMessage = foreign FFI_C "PQresultErrorMessage" (Ptr -> IO String)

    status : Ptr -> IO Int
    status = foreign FFI_C "PQstatus" (Ptr -> IO Int)

export
data PgConnection =
    MkPgConnection Ptr

export
data PgResult =
    MkPgResult Ptr

export
pgConnect : String -> IOExcept String PgConnection
pgConnect conninfo = IOM $ do
    conn <- raw.connectdb conninfo
    stat <- raw.status conn
    if stat == 0
        then pure (Right (MkPgConnection conn))
        else Left <$> errorMessage conn

export
pgExecute : PgConnection -> String -> IOExcept String PgResult
pgExecute (MkPgConnection conn) command = IOM $ do
    res <- raw.exec conn command
    err <- resultErrorMessage res
    pure $ if err == "" then Right (MkPgResult res) else Left err

export
pgRows : PgResult -> Int
pgRows (MkPgResult res) = unsafePerformIO $ raw.ntuples res

export
pgCols : PgResult -> Int
pgCols (MkPgResult res) = unsafePerformIO $ raw.nfields res

export
pgCell : PgResult -> Int -> Int -> Maybe String
pgCell (MkPgResult res) row col = unsafePerformIO $ do
    isnull <- raw.getisnull res row col
    if isnull == 1 then pure Nothing
                   else Just <$> raw.getvalue res row col

export
pgRow : PgResult -> Int -> List (Maybe String)
pgRow res row = map (pgCell res row) [0, 1 .. pgCols res - 1]

export
pgGrid : PgResult -> List (List (Maybe String))
pgGrid res = map (pgRow res) [0, 1 .. pgRows res - 1]

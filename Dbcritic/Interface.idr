module Dbcritic.Interface

export
formatMessage : Int -> String -> List String -> List String -> String
formatMessage index description problems solutions =
    "\x1B[34mISSUE #" ++ show index ++ ": " ++ description ++ "\x1B[0m\n" ++
    "\n" ++
    "\x1B[31m  If you do not solve this issue, you will encounter the following problems:\x1B[0m\n" ++
    "\n" ++
    concatMap (\p => "    \x1B[31m• " ++ p ++ "\x1B[0m\n") (problems) ++
    "\n" ++
    "\x1B[32m  You can solve this issue by taking one of the following measures:\x1B[0m\n" ++
    "\n" ++
    concatMap (\p => "    \x1B[32m• " ++ p ++ "\x1B[0m\n") (solutions)

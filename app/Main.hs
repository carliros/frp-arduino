{-# LANGUAGE CPP #-}
module Main where

import GHC
import GHC.Paths ( libdir )
import DynFlags
import Options.Applicative

data FrpArduino
    = FrpArduino {filePath :: String}

pFrpArduino :: Parser FrpArduino
pFrpArduino
    = FrpArduino <$> argument str (metavar "FilePath")

main :: IO ()
main = execParser opts >>= runWithOptions >> return ()
  where
    opts = info (helper <*> pFrpArduino)
                (fullDesc <> progDesc "Print a frp-arduino params" <> header "Frp-Arduino helper" )

runWithOptions (FrpArduino filePath) =
#if __GLASGOW_HASKELL__ > 704
          defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
#else
          defaultErrorHandler defaultLogAction $ do
#endif
            runGhc (Just libdir) $ do
              dFlags <- getSessionDynFlags
              let dFlagsPrime = foldl xopt_set dFlags
                                   [Opt_Cpp, Opt_ImplicitPrelude, Opt_MagicHash]
                  dFlagsPrimePrime = dFlagsPrime { objectDir = Just ""}
              setSessionDynFlags dFlagsPrimePrime
              target <- guessTarget filePath Nothing
              setTargets [target]
              load LoadAllTargets


{-
to review
    - https://s3.amazonaws.com/haddock.stackage.org/lts-5.14/ghc-7.10.3/src/DynFlags.html#DynFlags
    - https://s3.amazonaws.com/haddock.stackage.org/lts-5.14/ghc-7.10.3/DynFlags.html
    - https://wiki.haskell.org/GHC/As_a_library
    - https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/extending_ghc.html
-}
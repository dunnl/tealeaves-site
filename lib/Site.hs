{-# LANGUAGE OverloadedStrings #-}

module Site
    ( site
    ) where
--------------------------------------------------------------------------------
import Data.Default (Default(..))
import Data.List (reverse)
import Data.Monoid (mconcat, (<>))
import Hakyll
import Hakyll.Web.Sass
import Text.Pandoc.Options (ReaderOptions(..), WriterOptions(..), HTMLMathMethod(..))
import Text.Pandoc.Extensions
import Text.Pandoc.Definition
import Text.Pandoc.Walk
import System.FilePath.Posix ((</>), (-<.>))
import qualified System.FilePath.Posix as Posix

conf :: Configuration
conf = defaultConfiguration
  { deployCommand = "./extra/deploy.sh"
  , providerDirectory = "./site"
  }

--------------------------------------------------------------------------------
site :: IO ()
site = hakyllWith conf $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/**.js" $ do
        route   idRoute
        compile copyFileCompiler

    match "files/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "coqdocs/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "examples/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*.css" $ do
        route   idRoute
        compile compressCssCompiler

    match "css/*.sass" $ do
        dep <- makePatternDependency "vendor/bulma/**"
        rulesExtraDependencies [ dep ] $ do
            route $ setExtension "css"
            compile $ do
                let conf = sassDefConfig
                            { sassIncludePaths = Just  ["vendor/bulma"]}
                sassCompilerWith conf

    -- | Don't canonize the URL of these pages
    match (fromList ["404.html", "50x.html"]) $ do
        route $ idRoute
        compile $ do
            getResourceBody
            >>= loadAndApplyTemplate "templates/content.html" defaultContext
            >>= loadAndApplyTemplate "templates/top.html" defaultContext

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 3) . recentFirst =<< loadAll "posts/*"
            news  <- recentFirst =<< loadAll "news/*"
            let indexCtx =
                       listField "posts" siteContext (return posts)
                    <> listField "news" siteContext (return news)
                    <> defaultContext
            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/top.html" indexCtx

    -- Assets that must go in the root directory (e.g. icons)
    match "root/*" $ do
        route  routeTopLevel
        compile copyFileCompiler

    match "templates/*" $
        compile templateBodyCompiler

--------------------------------------------------------------------------------
htmlFilter :: Pandoc -> Pandoc
htmlFilter = walk replaceElements where
    replaceElements (CodeBlock (id, classes, kv) text) =
        CodeBlock (id, classes', kv) text
        where
            classes' = "prettyprint linenums":classes
    replaceElements block = block

readerOptions :: ReaderOptions
readerOptions =
  defaultHakyllReaderOptions


writerOptions :: WriterOptions
writerOptions =
  defaultHakyllWriterOptions
  { writerExtensions = githubMarkdownExtensions
  , writerHTMLMathMethod = MathJax ""
  }

-- | Rename `myfile.ext` to `myfile/index.ext` This allows us to use
-- `domain.tld/myfile/` vs.  `domain.tld/myfile.ext`
canonizeRoute :: Routes
canonizeRoute =
  customRoute $ \ident ->
    let fn = toFilePath ident
        dir = Posix.takeDirectory fn
        base = Posix.takeBaseName fn
        ext = Posix.takeExtension fn
    in dir </> base  </> "index" -<.> ext

-- | Drop redundant `/index.html` from a URL, if necessary
canonizeUrl :: String -> String
canonizeUrl url = canon
  where
    l = length ("index.html" :: String)
    canon =
        if "/index.html" == (reverse . take (l+1) . reverse $ url)
            then reverse $ drop l (reverse url)
            else url

getCanonicalRoute :: Identifier -> Compiler (Maybe FilePath)
getCanonicalRoute item = do
        mroute <- getRoute item
        return (canonizeUrl <$> mroute)

-- | Canonize URLs.
-- It is unfortunate to have to copy+paste Hakyll's code here,
-- but there's no way to map `canonizeUrl` over a `Context a`
canonicalUrlField :: String -> Context String
canonicalUrlField key = field key $ \i -> do
    let id = itemIdentifier i
        empty' = fail $ "No route url found for item " ++ show id
    fmap (maybe empty' toUrl) $ getCanonicalRoute id

-- | Global context
-- Note that an item's title will either be set explicitly in its metadata
-- or based on its filename (dropping up to the first '-')
siteContext :: Context String
siteContext = mconcat $
  [ metadataField
  , dateField "date" "%B %e, %Y"
  , bodyField "body"
  , titleField "title"
  , canonicalUrlField "url"
  , missingField
  ]

-- | Move an item to the top level
routeTopLevel :: Routes
routeTopLevel = customRoute (Posix.takeFileName. toFilePath)

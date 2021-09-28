module Page.Collection exposing (Model, Msg, Data, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import OptimizedDecoder as Decode exposing (Decoder)
import DataSource exposing (DataSource)
import DataSource.Glob as Glob
import DataSource.File as File
import Html exposing (Html)


type alias Model =
    ()


type alias Msg =
    Never

type alias RouteParams =
    {}

page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


type alias Data =
    {
        title : String,
        posts : List Post
        
    }
type alias Post = 
    { filePath : String
    , slug : String
    , title : String
    }

data : DataSource Data
data =
    DataSource.map2 (\a b -> {
        title = a,
        posts = b
    }) pageDecoder blogPosts
    
pageDecoder : DataSource String
pageDecoder = File.onlyFrontmatter (Decode.field "title" Decode.string) "site/index.md"


blogPosts :  DataSource (List Post)
blogPosts =
    Glob.succeed
        (\filePath slug ->
            { filePath = filePath
            , slug = slug
            }
        )
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "site/collection/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
        |> DataSource.map
            (List.map
                (\blogPost ->
                    File.onlyFrontmatter 
                    (postFrontmatterDecoder blogPost.filePath blogPost.slug ) 
                    blogPost.filePath
                )
            )
        |> DataSource.resolve


postFrontmatterDecoder : String -> String -> Decoder Post
postFrontmatterDecoder filePath slug =
    Decode.map3 Post
        (Decode.succeed filePath)
        (Decode.succeed slug)
        (Decode.field "title" Decode.string)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Collection"
    , body = [
        Html.ul [] (List.map (\post -> Html.li [] [Html.text post.title]) static.data.posts)
        ]
    }

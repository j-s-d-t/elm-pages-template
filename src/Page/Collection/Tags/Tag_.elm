module Page.Collection.Tags.Tag_ exposing (Model, Msg, Data, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import OptimizedDecoder as Decode exposing (Decoder)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import Page.Collection as Coll


type alias Model =
    ()


type alias Msg =
    Never

type alias RouteParams =
    { tag : Tag }

type alias Tag = 
    { slug : String
    , title : String
    }

type alias Item =
    { slug : String
    , title : String
    , tags : List String
    }

page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }

-- TODO: use a Set to collect all tag instances
routes : DataSource (List RouteParams)
routes =
    DataSource.succeed [
        { tag = "One" }
    ]


data : RouteParams -> DataSource Data
data routeParams =
    itemsData
    |> DataSource.map
        (\items ->
            items
            |> List.map (\item -> 
                { slug = item.slug
                , title = item.title
                , tags = item.tags
                }
            )
            |> List.filter (\a -> List.member routeParams.tag a.tags)
        )

itemsData : DataSource (List Item)
itemsData =
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
                (\item ->
                    File.onlyFrontmatter (itemFrontmatterDecoder item.slug) item.filePath
                )
            )
        |> DataSource.resolve

itemFrontmatterDecoder : String -> Decoder Item
itemFrontmatterDecoder slug =
    Decode.map3 Item
        (Decode.succeed slug)
        (Decode.field "title" Decode.string)
        (Decode.field "tags" <| Decode.list Decode.string)

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


type alias Data =
    List Item

view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    View.placeholder "Collection.Tags.Tag_"

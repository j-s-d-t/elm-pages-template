module Page.Collection.Tags.Tag_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html exposing (Html)
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Page.Collection as Coll
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { tag : String }


type alias Tag =
    { slug : String
    , title : String
    }


type alias Item =
    { slug : String
    , title : String
    , tags : List Tag
    }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }



-- TODO: Collect all tag instances and remove duplicates


routes : DataSource (List RouteParams)
routes =
    itemsData
        |> DataSource.map
            (\items ->
                items
                    -- Get all tags
                    |> List.concatMap (\item -> getTagSlugs item.tags)
                    |> List.map (\slug -> { tag = slug })
            )


data : RouteParams -> DataSource Data
data routeParams =
    itemsData
        |> DataSource.map
            (\items ->
                -- TODO: Need to populate the title with the title field of the current tag
                -- TODO: Need to filter out tag duplicates
                { title = ""
                , items =
                    items
                        |> List.map
                            (\item ->
                                { slug = item.slug
                                , title = item.title
                                , tags = item.tags
                                }
                            )
                        |> List.filter (\a -> List.member routeParams.tag <| getTagSlugs a.tags)
                }
            )


getTagSlugs : List Tag -> List String
getTagSlugs =
    List.map .slug


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
        (Decode.field "tags" <|
            Decode.list
                (Decode.string
                    |> Decode.andThen tagDecoder
                )
        )


tagDecoder : String -> Decoder Tag
tagDecoder tag =
    let
        slugFormat =
            tag
                |> String.trim
                |> String.replace " " "-"
                |> String.toLower
    in
    Decode.map2 Tag
        (Decode.succeed <| slugFormat)
        (Decode.succeed tag)


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
    { title : String
    , items : List Item
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    View.placeholder <| "Tag: " ++ static.data.title

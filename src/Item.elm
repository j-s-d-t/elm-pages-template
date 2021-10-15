module Item exposing (..)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import List.Extra exposing (unique)
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path exposing (..)
import Route
import Shared
import View exposing (View)



-- Items

-- contains all data definitions fot the Item type


type alias Item =
    { slug : String
    , title : String
    , tags : List Tag
    }


type alias Tag =
    ( String, String )


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


getAllTags : List Item -> List Tag
getAllTags items =
    items
        |> List.concatMap (\item -> item.tags)
        |> unique



-- Get the tag slugs


getTagSlugs : List Tag -> List String
getTagSlugs =
    List.map Tuple.first


itemFrontmatterDecoder : String -> Decoder Item
itemFrontmatterDecoder slug =
    Decode.map3 Item
        (Decode.succeed slug)
        (Decode.field "title" Decode.string)
        (Decode.field "tags" <|
            Decode.list (Decode.andThen tagDecoder Decode.string)
        )



-- Gather all the tags from all items, flatten the list and remove duplicates


tagDecoder : String -> Decoder Tag
tagDecoder tag =
    let
        slugFormat =
            tag
                |> String.trim
                |> String.replace " " "-"
                |> String.toLower
    in
    Decode.map2 Tuple.pair
        (Decode.succeed <| slugFormat)
        (Decode.succeed tag)

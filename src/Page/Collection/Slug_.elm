module Page.Collection.Slug_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import Head
import Head.Seo as Seo
import Html exposing (Html)
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Page.Collection as Coll
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Item
import Route exposing (Route(..))
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { slug : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    Item.itemsData
        |> DataSource.map
            (\routeParams ->
                routeParams
                    |> List.map
                        (\route ->
                            { slug = route.slug }
                        )
            )


data : RouteParams -> DataSource Data
data routeParams =
    File.bodyWithFrontmatter
        decoder
        ("site/collection/" ++ routeParams.slug ++ ".md")


decoder : String -> Decoder Data
decoder body =
    Decode.map (Data body)
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


type alias Data =
    { body : String
    , title : String
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.title
    , body =
        [ Html.h1 [] [ Html.text static.data.title ]
        , Html.text static.data.body
        ]
    }

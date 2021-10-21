module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import Head
import Head.Seo as Seo
import Html as H exposing (Html)
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Route
import View exposing (View)
import Html as H exposing (Html)
import Html.Attributes as Attr
import Markdown.Parser as Markdown
import Markdown.Renderer
import MarkdownRenderer


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


type alias Data =
    { body  : String
    , title : String
    }


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    File.bodyWithFrontmatter
        (decoder)
        ("site/index.md")
decoder : String -> Decoder Data
decoder   body =
    Decode.map (Data body)
        (Decode.field "title" Decode.string)



head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = static.sharedData.siteName
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = static.sharedData.siteName
        }
        |> Seo.website





view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Collection"
    , body =
        [ H.h1 [] [H.text static.data.title]
        , H.div [] (MarkdownRenderer.mdToHtml static.data.body)
        ]  
    }

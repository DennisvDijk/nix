# ketch

Use ketch tools when built-in `web_search`/`fetch_content`/`pi-worker-search` aren't enough.

## When to use which tool

| Task | Tool | Why not built-in |
| ------ | ------ | ----------------- |
| Quick web search | `web_search` (built-in) | Backend config already set up |
| Multi-engine search (federated) | `ketch_search` with `--multi` | Only ketch does RRF fusion |
| Search + full content extraction | `ketch_search --scrape` | One call, not two |
| Find real code examples | `ketch_code --lang go` | Pi has no code search |
| Curated library docs | `ketch_docs` | Pi has no docs surface |
| JS-rendered / SPA page | `ketch_scrape` (or `fetch_content` first, then ketch_scrape if it fails) | fetch_content returns minimal content for JS shells |
| CSS selector extraction | `ketch_scrape --select "article"` | fetch_content has no CSS selector support |
| Crawl a whole site section | `ketch_crawl` | Pi has no crawler |
| Single URL → markdown | `fetch_content` (cheaper, no subprocess) | ketch is heavier |
| Research question | `ketch_search --multi=ddg,brave --scrape` | Multi-engine + content in one pass |
| Library API usage patterns | `ketch_code "http.NewServerMux" --lang go --limit 10` | Real code beats blog posts |

## Quick reference

```
ketch_search query="context7 context deadline exceeded" --multi=ddg
ketch_search query="golang 1.24 changes" --scrape --limit 3
ketch_code query="http.HandleFunc" --lang go --limit 5
ketch_docs query="ServeMux" --library=/std/go/net/http --tokens=2000
ketch_scrape urls="https://example.com/docs" --max-chars=6000 --trim
ketch_crawl url="https://go.dev/doc/" --depth=2 --allow="effective_go,ref/spec"
```

## Backend setup

```bash
# DuckDuckGo works with zero config
ketch config set backend ddg

# Brave (free key)
ketch config set brave_api_key <key>

# Context7 docs (free key)
ketch config set context7_api_key <key>
```

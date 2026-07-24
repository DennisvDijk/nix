import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

/**
 * Pi extension wrapping ketch (https://github.com/1broseidon/ketch).
 *
 * Installs ketch via brew if missing, then registers 5 research tools:
 *   ketch_search  — web search (multi-backend, optional scrape)
 *   ketch_code    — public OSS code search (grep.app, Sourcegraph, GitHub)
 *   ketch_docs    — curated library docs (Context7)
 *   ketch_scrape  — URL → clean markdown (with JS rendering fallback)
 *   ketch_crawl   — BFS/sitemap crawler
 */

const KETCH_BIN = "ketch";
const KETCH_BREW = "1broseidon/tap/ketch";
const INSTALL_CMD = `brew install ${KETCH_BREW}`;

// ── helpers ──────────────────────────────────────────────────────────────────

function formatSearchResult(r: {
	title: string;
	url: string;
	description?: string;
	content?: string;
}): string {
	let s = `• [${r.title}](${r.url})`;
	if (r.description) s += `\n  ${r.description}`;
	if (r.content) s += `\n  Content: ${r.content.slice(0, 2000)}`;
	return s;
}

function formatCodeResult(r: {
	repo: string;
	path: string;
	line: number;
	snippet: string;
	url: string;
	source: string;
}): string {
	return `• [${r.repo}](${r.url})  (${r.source})\n  ${r.path}:${r.line}\n  \`${r.snippet}\``;
}

function formatDocResult(r: {
	library: string;
	title?: string;
	url?: string;
	snippet?: string;
}): string {
	return `• ${r.library}${r.title ? ` — ${r.title}` : ""}${r.url ? `\n  ${r.url}` : ""}${r.snippet ? `\n  ${r.snippet}` : ""}`;
}

function formatScrapeResult(r: {
	url: string;
	title: string;
	markdown?: string;
	error?: string;
}): string {
	if (r.error) return `• ${r.url}  — error: ${r.error}`;
	return `• ${r.title}\n  ${r.url}${r.markdown ? `\n  ${r.markdown.slice(0, 3000)}` : ""}`;
}

function formatCrawlResult(r: {
	url: string;
	title: string;
	body?: string;
	status?: string;
	error?: string;
}): string {
	if (r.error) return `• ${r.url}  — error: ${r.error}`;
	return `• ${r.title}\n  ${r.url}${r.body ? `\n  ${r.body.slice(0, 2000)}` : ""}`;
}

const KETCH_ERROR_MAP: Record<number, string> = {
	2: "bad input",
	3: "no results found",
	4: "upstream or network failure",
	5: "missing configuration (e.g. API key not set)",
	6: "cancelled or timed out",
};

function exitCodeLabel(code: number): string {
	return KETCH_ERROR_MAP[code] ?? `exit code ${code}`;
}

// ── extension factory ───────────────────────────────────────────────────────

export default async function (pi: ExtensionAPI) {
	// Ensure ketch is installed
	const { code: whichCode } = await pi.exec("which", [KETCH_BIN]);
	if (whichCode !== 0) {
		console.warn(
			`[ketch-ext] "${KETCH_BIN}" not found on PATH. ` +
				`Run \`${INSTALL_CMD}\` to install it. The ketch tools will report errors until it is available.`,
		);
	}

	// ── search ────────────────────────────────────────────────────────────────

	pi.registerTool({
		name: "ketch_search",
		label: "Ketch Search",
		description:
			"Search the web via ketch (Brave, DuckDuckGo, SearXNG, Exa, Firecrawl, Keenable). " +
			"Use instead of built-in web_search when you need multi-backend federation (--multi), " +
			"combined search+scrape (--scrape), or a specific backend. " +
			"Returns results with title, URL, description, and optional full content.",
		promptSnippet:
			"Search the web; supports federation and combined search+scrape via ketch",
		promptGuidelines: [
			"Use ketch_search when you need multi-backend federation (--multi) or combined search+scrape (--scrape).",
			"Use ketch_search or ketch_scrape when fetch_content fails on JS-heavy pages.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
			limit: Type.Optional(
				Type.Integer({
					description: "Max results (default 5)",
					minimum: 1,
					maximum: 20,
				}),
			),
			backend: Type.Optional(
				Type.String({
					description: "Backend: brave, ddg, searxng, exa, firecrawl, keenable",
				}),
			),
			scrape: Type.Optional(
				Type.Boolean({
					description: "Fetch and extract full content from each result",
				}),
			),
			multi: Type.Optional(
				Type.String({
					description:
						'Federated search across backends. "all" or comma-separated list (brave,ddg,exa). Mutually exclusive with backend.',
				}),
			),
			random: Type.Optional(
				Type.String({
					description:
						'Random backend with fallback. "all" or comma-separated list. Mutually exclusive with backend and multi.',
				}),
			),
			max_chars: Type.Optional(
				Type.Integer({
					description:
						"Truncate scraped content to N chars (default 0 = disabled)",
				}),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate) {
			const args: string[] = ["search", params.query, "--json"];

			if (params.limit) args.push("--limit", String(params.limit));
			if (params.backend) args.push("--backend", params.backend);
			if (params.scrape) args.push("--scrape");
			if (params.multi) args.push("--multi", params.multi);
			if (params.random) args.push("--random", params.random);
			if (params.max_chars) args.push("--max-chars", String(params.max_chars));

			const { stdout, stderr, code } = await pi.exec(KETCH_BIN, args, {
				signal,
				timeout: 60000,
			});

			if (code === 3) {
				return {
					content: [{ type: "text", text: "No search results found." }],
					details: { results: [] },
				};
			}

			if (code !== 0) {
				const label = exitCodeLabel(code);
				const detail = stderr || stdout || "(no output)";
				throw new Error(`ketch search ${label}: ${detail}`);
			}

			let results: Array<Record<string, unknown>>;
			try {
				results = JSON.parse(stdout);
			} catch {
				throw new Error(
					`ketch search returned invalid JSON: ${stdout.slice(0, 500)}`,
				);
			}

			if (!Array.isArray(results) || results.length === 0) {
				return {
					content: [{ type: "text", text: "No search results found." }],
					details: { results: [] },
				};
			}

			const lines = results.map(formatSearchResult);
			const text = lines.join("\n\n");

			return {
				content: [{ type: "text", text }],
				details: { results, count: results.length },
			};
		},
	});

	// ── code search ───────────────────────────────────────────────────────────

	pi.registerTool({
		name: "ketch_code",
		label: "Ketch Code Search",
		description:
			"Search public OSS source code via ketch (grep.app, Sourcegraph, GitHub Code Search). " +
			"Supports language filtering and regex. Returns repo, file path, line number, matching snippet, and URL. " +
			"Use when you need real-world code examples or want to see how a library/API is used in practice.",
		promptSnippet:
			"Search public OSS source code — see how libraries are actually used",
		promptGuidelines: [
			"Use ketch_code instead of web search when you need real code examples — it greps 1M+ public repos.",
			"Use --lang to filter by language (go, ts, py, rs, etc.) and --regex for pattern matching.",
		],
		parameters: Type.Object({
			query: Type.String({
				description: "Code search query (literal or regex)",
			}),
			lang: Type.Optional(
				Type.String({
					description: "Language filter (e.g. go, ts, py, rs, java)",
				}),
			),
			limit: Type.Optional(
				Type.Integer({
					description: "Max results (default 5)",
					minimum: 1,
					maximum: 20,
				}),
			),
			backend: Type.Optional(
				Type.String({
					description: "Backend: grepapp (default), sourcegraph, github",
				}),
			),
			regex: Type.Optional(
				Type.Boolean({
					description: "Interpret query as a regular expression",
				}),
			),
			minimal: Type.Optional(
				Type.Boolean({
					description: "One result per line, tab-separated (url/repo/snippet)",
				}),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate) {
			const args: string[] = ["code", params.query, "--json"];

			if (params.lang) args.push("--lang", params.lang);
			if (params.limit) args.push("--limit", String(params.limit));
			if (params.backend) args.push("--backend", params.backend);
			if (params.regex) args.push("--regex");
			if (params.minimal) args.push("--minimal");

			const { stdout, stderr, code } = await pi.exec(KETCH_BIN, args, {
				signal,
				timeout: 30000,
			});

			if (code === 3) {
				return {
					content: [{ type: "text", text: "No code search results found." }],
					details: { results: [] },
				};
			}

			if (code !== 0) {
				const label = exitCodeLabel(code);
				const detail = stderr || stdout || "(no output)";
				throw new Error(`ketch code ${label}: ${detail}`);
			}

			let results: Array<Record<string, unknown>>;
			try {
				results = JSON.parse(stdout);
			} catch {
				throw new Error(
					`ketch code returned invalid JSON: ${stdout.slice(0, 500)}`,
				);
			}

			if (!Array.isArray(results) || results.length === 0) {
				return {
					content: [{ type: "text", text: "No code search results found." }],
					details: { results: [] },
				};
			}

			const lines = results.map(formatCodeResult);
			const text = ["Code Search Results:\n" + lines.join("\n\n")];

			return {
				content: [{ type: "text", text: text.join("\n") }],
				details: { results, count: results.length },
			};
		},
	});

	// ── docs ──────────────────────────────────────────────────────────────────

	pi.registerTool({
		name: "ketch_docs",
		label: "Ketch Docs",
		description:
			"Search curated, version-aware library documentation via Context7. " +
			"Returns documentation snippets for popular libraries and frameworks. " +
			"Requires a Context7 API key (ketch config set context7_api_key <key>).",
		promptSnippet:
			"Search curated library documentation (version-aware snippets, Context7)",
		promptGuidelines: [
			"Use ketch_docs when you need authoritative library documentation — it returns curated snippets, not random web pages.",
			"Pass a library ID with --library to skip the name-resolution step and get docs directly.",
			"Use --resolve to look up a library name and see available IDs without fetching docs.",
		],
		parameters: Type.Object({
			query: Type.Optional(
				Type.String({
					description:
						"Search query within library docs (omit to list all snippets)",
				}),
			),
			library: Type.Optional(
				Type.String({
					description:
						"Context7 library ID (e.g. /std/go/net/http). Skip name-resolution step.",
				}),
			),
			limit: Type.Optional(
				Type.Integer({
					description: "Max results (default 5)",
					minimum: 1,
					maximum: 20,
				}),
			),
			tokens: Type.Optional(
				Type.Integer({
					description: "Token budget (default 4000)",
					minimum: 1000,
					maximum: 16000,
				}),
			),
			resolve: Type.Optional(
				Type.Boolean({
					description: "Resolve library name instead of searching",
				}),
			),
			minimal: Type.Optional(
				Type.Boolean({ description: "One result per line, tab-separated" }),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate) {
			const args: string[] = ["docs", "--json"];

			if (params.query) args.push(params.query);
			else if (!params.library && !params.resolve) args.push("");
			if (params.library) args.push("--library", params.library);
			if (params.limit) args.push("--limit", String(params.limit));
			if (params.tokens) args.push("--tokens", String(params.tokens));
			if (params.resolve) args.push("--resolve");
			if (params.minimal) args.push("--minimal");

			const { stdout, stderr, code } = await pi.exec(KETCH_BIN, args, {
				signal,
				timeout: 30000,
			});

			if (code === 3) {
				return {
					content: [{ type: "text", text: "No docs results found." }],
					details: { results: [] },
				};
			}

			if (code === 5) {
				return {
					content: [
						{
							type: "text",
							text:
								"ketch docs requires a Context7 API key.\n" +
								"Run: ketch config set context7_api_key <key>\n" +
								"Get a free key at https://context7.com",
						},
					],
					details: { results: [] },
				};
			}

			if (code !== 0) {
				const label = exitCodeLabel(code);
				const detail = stderr || stdout || "(no output)";
				throw new Error(`ketch docs ${label}: ${detail}`);
			}

			let results: Array<Record<string, unknown>>;
			try {
				results = JSON.parse(stdout);
			} catch {
				throw new Error(
					`ketch docs returned invalid JSON: ${stdout.slice(0, 500)}`,
				);
			}

			if (!Array.isArray(results) || results.length === 0) {
				return {
					content: [{ type: "text", text: "No docs results found." }],
					details: { results: [] },
				};
			}

			const lines = results.map(formatDocResult);
			const text = "Documentation Results:\n\n" + lines.join("\n\n");

			return {
				content: [{ type: "text", text }],
				details: { results, count: results.length },
			};
		},
	});

	// ── scrape ────────────────────────────────────────────────────────────────

	pi.registerTool({
		name: "ketch_scrape",
		label: "Ketch Scrape",
		description:
			"Fetch one or more URLs and extract clean markdown via ketch. " +
			"Handles JS-rendered pages (React/Vue/Svelte SPAs) via headless Chrome fallback, " +
			"PDF text extraction, and CSS selector targeting. " +
			"Use when fetch_content fails on JS-heavy pages or you need CSS selector extraction.",
		promptSnippet:
			"Fetch URL(s) and extract clean markdown; handles JS-rendered pages and PDFs",
		promptGuidelines: [
			"Use ketch_scrape when fetch_content fails on JS-heavy or SPA pages — ketch uses headless Chrome fallback.",
			"Limit max_chars to 4000-8000 for unknown pages to avoid token waste.",
			"Use --select with a CSS selector to extract specific page elements.",
			"Multi-URL scraping returns per-result errors inside a successful call; check the error field.",
		],
		parameters: Type.Object({
			urls: Type.Union(
				[
					Type.String({ description: "Single URL to scrape" }),
					Type.Array(Type.String({ description: "Multiple URLs to scrape" })),
				],
				{ description: "URL or array of URLs to scrape" },
			),
			max_chars: Type.Optional(
				Type.Integer({
					description: "Truncate markdown to N chars (default 0 = disabled)",
				}),
			),
			select: Type.Optional(
				Type.String({
					description:
						"CSS selector to extract specific elements (skips readability extraction)",
				}),
			),
			trim: Type.Optional(
				Type.Boolean({
					description: "Strip markdown formatting, keep content text only",
				}),
			),
			no_cache: Type.Optional(
				Type.Boolean({ description: "Bypass the page cache" }),
			),
			no_llms_txt: Type.Optional(
				Type.Boolean({
					description: "Disable automatic /llms.txt detection for bare domains",
				}),
			),
			force_browser: Type.Optional(
				Type.Boolean({
					description:
						"Always render via headless Chrome (requires browser setup)",
				}),
			),
			concurrency: Type.Optional(
				Type.Integer({
					description:
						"Max concurrent requests for multi-URL scraping (default 5)",
				}),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate) {
			const urls = Array.isArray(params.urls) ? params.urls : [params.urls];
			if (urls.length === 0) throw new Error("At least one URL is required");

			const args: string[] = ["scrape", "--json"];

			if (params.max_chars) args.push("--max-chars", String(params.max_chars));
			if (params.select) args.push("--select", params.select);
			if (params.trim) args.push("--trim");
			if (params.no_cache) args.push("--no-cache");
			if (params.no_llms_txt) args.push("--no-llms-txt");
			if (params.force_browser) args.push("--force-browser");
			if (params.concurrency)
				args.push("--concurrency", String(params.concurrency));

			// ketch scrape accepts URLs as positional args
			args.push(...urls);

			const { stdout, stderr, code } = await pi.exec(KETCH_BIN, args, {
				signal,
				timeout: 120000,
			});

			if (code !== 0) {
				const label = exitCodeLabel(code);
				const detail = stderr || stdout || "(no output)";
				throw new Error(`ketch scrape ${label}: ${detail}`);
			}

			let results: Array<Record<string, unknown>>;
			try {
				const parsed = JSON.parse(stdout);

				// Single URL returns object, multi-URL returns array
				if (Array.isArray(parsed)) {
					results = parsed;
				} else if (parsed && typeof parsed === "object") {
					results = [parsed as Record<string, unknown>];
				} else {
					throw new Error(`unexpected JSON shape: ${stdout.slice(0, 200)}`);
				}
			} catch (e: unknown) {
				const msg = e instanceof Error ? e.message : "unknown error";
				throw new Error(`ketch scrape returned invalid JSON: ${msg}`);
			}

			const lines = results.map(formatScrapeResult);
			const text = lines.join("\n\n");

			return {
				content: [{ type: "text", text }],
				details: { results, count: results.length, urls },
			};
		},
	});

	// ── crawl ─────────────────────────────────────────────────────────────────

	pi.registerTool({
		name: "ketch_crawl",
		label: "Ketch Crawl",
		description:
			"BFS crawl a website from a seed URL, extracting clean markdown from each discovered page, via ketch. " +
			"Use when you need content from many pages of a site (documentation, blogs, etc.). " +
			"Outputs per-page markdown. Respects depth limits and deny patterns.",
		promptSnippet:
			"Crawl a website — extract markdown from many pages starting from a seed URL",
		promptGuidelines: [
			"Use ketch_crawl instead of repeated ketch_scrape when you need multiple pages from one site.",
			"Set --depth to control crawl depth (default 3), --allow/--deny for path filters.",
			"Use --sitemap to crawl from a sitemap.xml URL.",
		],
		parameters: Type.Object({
			url: Type.String({ description: "Seed URL to start crawling from" }),
			depth: Type.Optional(
				Type.Integer({
					description: "Max BFS depth (default 3)",
					minimum: 1,
					maximum: 10,
				}),
			),
			allow: Type.Optional(
				Type.Array(Type.String(), {
					description:
						"Path substring filters — only pages whose URL contains at least one of these are included",
				}),
			),
			deny: Type.Optional(
				Type.Array(Type.String(), {
					description: "Regex deny patterns — pages matching any are excluded",
				}),
			),
			sitemap: Type.Optional(
				Type.Boolean({ description: "Treat seed URL as a sitemap.xml" }),
			),
			concurrency: Type.Optional(
				Type.Integer({
					description: "Worker pool size (default 8)",
					minimum: 1,
					maximum: 32,
				}),
			),
			no_cache: Type.Optional(
				Type.Boolean({ description: "Bypass the page cache" }),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate) {
			const args: string[] = ["crawl", params.url, "--json"];

			if (params.depth) args.push("--depth", String(params.depth));
			if (params.allow && params.allow.length > 0) {
				for (const a of params.allow) args.push("--allow", a);
			}
			if (params.deny && params.deny.length > 0) {
				for (const d of params.deny) args.push("--deny", d);
			}
			if (params.sitemap) args.push("--sitemap");
			if (params.concurrency)
				args.push("--concurrency", String(params.concurrency));
			if (params.no_cache) args.push("--no-cache");

			const { stdout, stderr, code } = await pi.exec(KETCH_BIN, args, {
				signal,
				timeout: 180000,
			});

			if (code === 3) {
				return {
					content: [{ type: "text", text: "Crawl found no pages." }],
					details: { results: [] },
				};
			}

			if (code !== 0) {
				const label = exitCodeLabel(code);
				const detail = stderr || stdout || "(no output)";
				throw new Error(`ketch crawl ${label}: ${detail}`);
			}

			// crawl --json outputs NDJSON — one JSON object per line
			const lines = stdout.trim().split("\n").filter(Boolean);
			const results: Array<Record<string, unknown>> = [];

			for (const line of lines) {
				try {
					results.push(JSON.parse(line) as Record<string, unknown>);
				} catch {
					// skip malformed lines
				}
			}

			if (results.length === 0) {
				return {
					content: [{ type: "text", text: "Crawl found no pages." }],
					details: { results: [] },
				};
			}

			const formatted = results.map(formatCrawlResult);
			const text =
				`Crawl Results (${results.length} pages):\n\n` + formatted.join("\n\n");

			return {
				content: [{ type: "text", text }],
				details: { results, count: results.length, seed: params.url },
			};
		},
	});
}

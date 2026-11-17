# AGENTS.md

CNIPDb collects Chinese IP ranges from multiple sources and publishes each source independently in TXT, DAT (V2Ray) and MMDB (MaxMind) formats; consumers pick a source. See [README.md](README.md) for download links and format descriptions.

## HANDOVER.md

When a multi-step task is interrupted, write progress to `HANDOVER.md` so the next session can pick up where you left off. Include: what was done, what remains, key decisions made, and the next concrete step. Delete the file when the task is complete.

## Behavioral Guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

**Additional rules:**
- Be concise in output but thorough in reasoning.
- Do not re-read files you have already read.
- User instructions always override this file.
- Don't wrestle with indentation in the Edit tool — focus on logic, let the project's formatter fix formatting. Use `sed` or `python3` freely when the Edit tool struggles with whitespace.

## Git commit convention

Every commit subject starts with a type prefix — `feat` / `fix` / `chore` / `docs` / `revert` / `refactor` / `perf` / `test` / `build` — optionally scoped: `fix(toolbar): ...`. Subject: imperative, lowercase start, no trailing period, aim ≤ 72 chars; detail goes in the body after a blank line (why, not what); breaking changes take `!` before the colon or a `BREAKING CHANGE:` body footer. Never rewrite pushed history.

- Commit incrementally — one logical change per commit, after lint and tests pass. Present changes for review before committing.
- PRs: link the issue, summarize the change and verification (tests/benchmarks), and include config/log/pprof evidence for bug fixes.

### Co-Author Format

- Always add co-author information. If closing an issue in commit text, verify against `main` first: `gh issue view <issue-id>`.
- Only ONE co-author line is allowed. If multiple agents contributed, aggregate into ONE entry.

Format: `Co-authored-by: <AgentName> <Email>`

Valid examples (choose EXACTLY ONE):

```
Co-authored-by: ZCode <noreply@z.ai>
```

## Documentation format

Family-wide Markdown rules, shared verbatim across all ZJ projects:

- **Language**: AGENTS.md, AUDIT.md, DESIGN.md and other agent-facing docs are English; README.md is Chinese (human-facing). Keep literal UI strings and code identifiers verbatim.
- **AGENTS.md skeleton** — generic sections first, then project; omit sections that don't apply, keep the order:
  `# AGENTS.md` → 1–2 sentence intro (what the project is + key doc links) → Behavioral Guidelines → Git commit convention → Documentation format → Project → Commands → Architecture → Conventions (Gotchas as a subsection) → project-specific sections → Key Docs.
- **README.md skeleton**: `# <project>` → badge block → one-line positioning + stack + key links → 特性 → 快速开始 → 配置 / 用法 → 文档 → License (omit as needed).
- **README badges** (shields.io, after the title, in order): Version (only where a real version exists, linked to the repo's GitHub releases), License (Apache 2.0 with Commons Clause — every project), primary-language badge (Go / TypeScript / Bash / Python / Docker), Biome for TypeScript projects; pure data/config repos get License only. Version links use the real GitHub repo name.
- **Formatting**: ATX headings (`#`), never skip a level; code fences always carry a language tag (`bash`, `go`, `json`, `text` for trees); tables for structured reference; no decorative emoji in headings or bullets; bold for key terms only.

## Project

CNIPDb is a multi-source IP data collection project that:
- Collects IP data from multiple sources (BGP, BTPanel, DB-IP, GeoLite2, IANA, IP2Location, IPdeny, IPinfo.io, IPIPdotNET, IPtoASN, OpenIPDB)
- Merges adjacent/overlapping CIDR blocks natively in Python (`ipaddress.collapse_addresses`)
- Outputs TXT, DAT (V2Ray) and MMDB (MaxMind) for IPv4, IPv6 and combined lists
- Runs daily via GitHub Actions to keep data current

## Commands

### Full Build Process
```bash
# Run the complete build (downloads from all sources, converts changed files)
python3 build.py
```

Token-protected sources read their credentials from environment variables:
```bash
GEOLITE2_TOKEN=... IP2LOCATION_TOKEN=... IPINFOIO_TOKEN=... python3 build.py
```

### Testing Individual Sources
`build.py` is importable; each source is a standalone function:
```bash
python3 -c "import build; build.get_data_from_bgp(); build.environment_cleanup()"
```

## Architecture

1. **Collection**: each `get_data_from_<source>()` downloads its URLs in parallel, extracts Chinese ranges and splits IPv4/IPv6.
2. **Merge**: `merge()` collapses and sorts networks; `write_txt()` writes `cn-ipv4.txt`, `cn-ipv6.txt`, `cn-all.txt` into `sources/<source>/`.
3. **Conversion**: `environment_cleanup()` runs `geoip convert` for every source TXT file that changed according to `git status`, writing DAT/MMDB next to the TXT. There is no aggregated output; consumers pick a source.

## Conventions

### Python (build.py)
1. snake_case for functions and variables; descriptive `get_data_from_<source>` names
2. 4-space indentation, stdlib only (no pip dependencies)
3. Downloads go through `download()`/`fetch()` so tests can inject fixtures
4. Failed downloads return empty data; a source with no data writes empty files (like the original `cat | cidr-merger` redirects)

### Gotchas
- `geoip` embeds a `build_epoch` timestamp in MMDB output: two runs never produce byte-identical `.mmdb` files. Compare MMDB data with the epoch masked.
- `geoip` exits non-zero on empty input ("entry CN has no prefix"); the build ignores that exit code, like the original.
- `geoip convert` resolves the `../sources/<name>` paths in `templates/*.json` relative to `./Temp`; the config path passed to it must be absolute, and `TARGET` in a template is the placeholder replaced with the source name.
- CIDR merging is done by `ipaddress`, not `cidr-merger`; output ordering is `(version, network_address, prefixlen)`, verified byte-identical to `cidr-merger -s`.
- IP2Location IPv4-mapped IPv6 ranges (`::ffff:`) are dropped, like the original `grep -v '^::ffff:'`.

### File Naming
- Source directories: `sources/<source>`
- Output files: `cn-<ipv4|ipv6|all>.<txt|dat|mmdb>`; IPv4-only sources (btpanel, ipipdotnet, openipdb) only have `cn-ipv4.*`

## Dependencies

- Python 3.9+ (stdlib only)
- `geoip` (Go, github.com/Loyalsoldier/geoip) for DAT/MMDB conversion
- `git` (change detection for conversions)

## Adding New Data Sources

1. Add a `get_data_from_<source>()` function following the existing pattern
2. Call it from `main()`
3. Update this documentation and README.md

## GitHub Actions Integration

- Daily at 00:00 UTC, plus manual `workflow_dispatch`
- Installs the `geoip` Go tool, runs `python3 build.py`, commits and pushes changes
- Secrets: `GEOLITE2_TOKEN`, `IP2LOCATION_TOKEN`, `IPINFOIO_TOKEN` (passed as environment variables)

## Key Docs

- [README.md](README.md) — download links and format descriptions (Chinese)
- `templates/*.json` — geoip conversion templates (TARGET placeholder)

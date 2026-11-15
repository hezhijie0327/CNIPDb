# AGENTS.md

This repository collects and aggregates Chinese IP ranges from multiple sources, providing them in various formats for different use cases. See [README.md](README.md) for download links and format descriptions.

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
- **README.md skeleton**: `# <project>` → one-line positioning + stack + key links → 特性 → 快速开始 → 配置 / 用法 → 文档 → License (omit as needed).
- **Formatting**: ATX headings (`#`), never skip a level; code fences always carry a language tag (`bash`, `go`, `json`, `text` for trees); tables for structured reference; no decorative emoji in headings or bullets; bold for key terms only.

## Project

CNIPDb is a data aggregation project that:
- Collects IP data from multiple sources (BGP, DB-IP, GeoLite2, IANA, etc.)
- Processes and merges the data into consolidated IP ranges
- Outputs in multiple formats: TXT, DAT (V2Ray), and MMDB (MaxMind)
- Supports both IPv4 and IPv6 addresses
- Runs daily via GitHub Actions to keep data current

## Commands

### Full Build Process
```bash
# Run the complete build process (downloads from all sources)
./release.sh
```

### Manual Data Collection
The release script automatically handles:
1. Environment preparation
2. Data collection from all sources
3. Processing and merging IP ranges
4. Format conversion to DAT and MMDB
5. Cleanup

### Testing Individual Sources
To test data collection from a specific source, extract and run individual functions from release.sh:
```bash
# Example: BGP data collection only
EnvironmentPreparation
GetDataFromBGP
EnvironmentCleanup
```

## Conventions

### Shell Scripting (release.sh)
1. Use snake_case for function and variable names
2. Prefix functions with descriptive verbs (e.g., GetDataFrom)
3. Use consistent indentation (4 spaces)
4. Add descriptive comments for complex logic
5. Quote all variables to handle spaces properly
6. Use `local` for function-local variables

### File Naming Conventions
- Data directories: `cnipdb_<source>` (e.g., cnipdb_bgp, cnipdb_dbip)
- Output files: `country_<ipv|ipv4|ipv6>.<format>`
  - IPv4 only: `country_ipv4.txt`, `country_ipv4.dat`, `country_ipv4.mmdb`
  - IPv6 only: `country_ipv6.txt`, `country_ipv6.dat`, `country_ipv6.mmdb`
  - Combined: `country_ipv4_6.txt`, `country_ipv4_6.dat`, `country_ipv4_6.mmdb`

### Configuration Files (JSON)
- Use consistent indentation (2 spaces)
- Include descriptive comments in the script that generates them
- Maintain proper JSON structure with arrays for input/output configurations

## Project structure

- `cnipdb_*` directories: Output directories for different data sources
- `script/`: JSON configuration templates for format conversion
- `.github/workflows/main.yml`: CI/CD pipeline configuration
- `release.sh`: Main build script that orchestrates the entire process

## Data Processing Workflow

1. **Collection Phase**:
   - Download raw data from each source
   - Extract Chinese IP ranges
   - Separate IPv4 and IPv6 addresses

2. **Processing Phase**:
   - Sort and deduplicate IP ranges
   - Merge adjacent/overlapping CIDR blocks
   - Generate combined IPv4+IPv6 files

3. **Output Phase**:
   - Convert TXT files to DAT format (V2Ray)
   - Convert TXT files to MMDB format (MaxMind)
   - All files placed in respective `cnipdb_*` directories

## Error Handling

- All curl commands include timeout and error handling
- Use temporary files and directories for processing
- Cleanup is handled in the EnvironmentCleanup function
- GitHub Actions includes error reporting via Git commit messages

## Dependencies

External tools required:
- `curl`: For downloading data
- `cidr-merger`: Go tool for merging CIDR blocks
- `geoip`: Go tool for converting between formats
- `bc`: For numeric calculations (IP2Location)
- `gzip`, `unzip`: For decompression
- Standard Unix tools: `cut`, `grep`, `sort`, `uniq`, `awk`, `sed`

## Adding New Data Sources

To add a new IP data source:

1. Create a new function `GetDataFrom<SourceName>`
2. Follow the existing pattern:
   - Download data using curl
   - Extract Chinese IP ranges
   - Separate IPv4/IPv6 if needed
   - Create output directory: `../cnipdb_<sourcename>`
   - Generate sorted, deduplicated text files
3. Add the function call to the main process in release.sh
4. Update this documentation with the new source

## GitHub Actions Integration

The automated workflow:
1. Triggers daily at midnight UTC
2. Can be triggered manually
3. Installs required Go tools
4. Runs the complete build process
5. Commits and pushes any changes

The workflow handles sensitive data via GitHub Secrets:
- `GEOLITE2_TOKEN`: For MaxMind GeoLite2 API
- `IP2LOCATION_TOKEN`: For IP2Location API
- `IPINFOIO_TOKEN`: For IPinfo.io API

## Output Format Details

### TXT Format
Simple CIDR notation, one range per line:
```text
1.2.3.0/24
2001:db8::/32
```

### DAT Format
Binary format for V2Ray compatible tools
- Generated using `geoip` tool with JSON configuration
- Separate files for IPv4, IPv6, and combined

### MMDB Format
MaxMind database format
- Generated using `geoip` tool with JSON configuration
- Compatible with standard MMDB readers
- Separate files for IPv4, IPv6, and combined

# CNIPDb - China IP Database Development Guide

This repository collects and aggregates Chinese IP ranges from multiple sources, providing them in various formats for different use cases.

## Project Overview

CNIPDb is a data aggregation project that:
- Collects IP data from multiple sources (BGP, DB-IP, GeoLite2, IANA, etc.)
- Processes and merges the data into consolidated IP ranges
- Outputs in multiple formats: TXT, DAT (V2Ray), and MMDB (MaxMind)
- Supports both IPv4 and IPv6 addresses
- Runs daily via GitHub Actions to keep data current

## Build Commands

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

## Project Structure

- `cnipdb_*` directories: Output directories for different data sources
- `script/`: JSON configuration templates for format conversion
- `.github/workflows/main.yml`: CI/CD pipeline configuration
- `release.sh`: Main build script that orchestrates the entire process

## Code Style Guidelines

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
```
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
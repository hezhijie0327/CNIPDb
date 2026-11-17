#!/usr/bin/env python3

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && python3 ./CNIPDb/build.py

import gzip
import io
import ipaddress
import json
import math
import os
import subprocess
import zipfile
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent
SOURCE_DIR = ROOT / "sources"

BGP_URL = (
    "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt",
    "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt",
    "https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt",
)
BTPANEL_URL = (
    "https://download.bt.cn/cnlist.json",
)
DBIP_URL = (
    f"https://download.db-ip.com/free/dbip-country-lite-{datetime.now(timezone.utc).strftime('%Y-%m')}.csv.gz",
)
GEOLITE2_URL = (
    "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV"
    f"&license_key={os.environ.get('GEOLITE2_TOKEN', '')}&suffix=zip",
)
IANA_URL = (
    "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest",
    "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest",
    "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest",
    "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest",
    "https://ftp.apnic.net/stats/iana/delegated-iana-latest",
    "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest",
    "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest",
    "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest",
    "https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest",
    "https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest",
)
IP2LOCATION_URL = (
    f"https://www.ip2location.com/download/?token={os.environ.get('IP2LOCATION_TOKEN', '')}&file=DB1LITECSVIPV6",
    f"https://www.ip2location.com/download/?token={os.environ.get('IP2LOCATION_TOKEN', '')}&file=DB1LITECSV",
)
IPINFOIO_URL = (
    f"https://ipinfo.io/data/free/country.csv.gz?token={os.environ.get('IPINFOIO_TOKEN', '')}",
)
IPDENY_URL = (
    "http://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone",
    "http://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone",
)
IPIPDOTNET_URL = (
    "https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt",
    "https://raw.githubusercontent.com/zhufengme/block_cn_files/refs/heads/master/cn_ip_list.txt",
)
IPTOASN_URL = (
    "https://iptoasn.com/data/ip2country-v4.tsv.gz",
    "https://iptoasn.com/data/ip2country-v6.tsv.gz",
)
OPENIPDB_URL = (
    "https://raw.githubusercontent.com/metowolf/iplist/master/data/country/CN.txt",
)


## Function
# Download one URL, return bytes (empty on failure, like curl -s)
def download(url):
    try:
        request = Request(url, headers={"User-Agent": "curl/8"})
        with urlopen(request, timeout=15) as response:
            return response.read()
    except OSError:
        return b""


# Fetch all URLs in parallel and concatenate (raw append, like curl >> file)
def fetch(urls):
    with ThreadPoolExecutor(max_workers=16) as pool:
        return b"".join(pool.map(download, urls))


# Parse CIDR lines, skipping anything invalid
def parse_networks(lines):
    networks = []
    for line in lines:
        try:
            networks.append(ipaddress.ip_network(line.strip(), strict=False))
        except ValueError:
            continue
    return networks


# Merge adjacent/overlapping networks (replaces cidr-merger -s)
def merge(networks):
    collapsed = ipaddress.collapse_addresses(networks)
    return sorted(collapsed, key=lambda n: (n.version, int(n.network_address), n.prefixlen))


# Expand an inclusive address range into minimal CIDRs
def range_networks(start, end):
    return list(ipaddress.summarize_address_range(ipaddress.ip_address(start), ipaddress.ip_address(end)))


# Split raw text lines into IPv4/IPv6 like the original grep filters
def split_lines(text):
    ipv4, ipv6 = [], []
    for line in text.split("\n"):
        if not line or "#" in line:
            continue
        if ":" not in line:
            ipv4.append(line)
        elif "." not in line:
            ipv6.append(line)
    return ipv4, ipv6


# Write cn-ipv4/ipv6/all.txt for one directory (empty files included,
# like the original cat | cidr-merger redirects)
def write_txt(out_dir, ipv4=(), ipv6=(), ipv6_enabled=True):
    out_dir.mkdir(parents=True, exist_ok=True)
    ipv4 = merge(ipv4)
    ipv6 = merge(ipv6)
    (out_dir / "cn-ipv4.txt").write_text("\n".join(str(n) for n in ipv4) + "\n" if ipv4 else "")
    if ipv6_enabled:
        (out_dir / "cn-ipv6.txt").write_text("\n".join(str(n) for n in ipv6) + "\n" if ipv6 else "")
        (out_dir / "cn-all.txt").write_text(
            "\n".join(str(n) for n in ipv4 + ipv6) + "\n" if ipv4 or ipv6 else ""
        )


# Decompress helpers tolerant of failed downloads (empty input)
def try_gzip(data):
    try:
        return gzip.decompress(data)
    except (OSError, EOFError):
        return b""


def try_zip(data):
    try:
        return zipfile.ZipFile(io.BytesIO(data))
    except (zipfile.BadZipFile, OSError):
        return None


# Get Data from BGP
def get_data_from_bgp():
    ipv4, ipv6 = split_lines(fetch(BGP_URL).decode("utf-8", errors="replace"))
    write_txt(SOURCE_DIR / "bgp", parse_networks(ipv4), parse_networks(ipv6))


# Get Data from BTPanel
def get_data_from_btpanel():
    try:
        data = json.loads(fetch(BTPANEL_URL).decode("utf-8", errors="replace"))
    except ValueError:
        data = []
    networks = []
    for start, end in data:
        networks.extend(range_networks(".".join(map(str, start)), ".".join(map(str, end))))
    write_txt(SOURCE_DIR / "btpanel", ipv4=networks, ipv6_enabled=False)


# Get Data from DBIP
def get_data_from_dbip():
    text = try_gzip(fetch(DBIP_URL)).decode("utf-8", errors="replace")
    ipv4, ipv6 = [], []
    for line in text.split("\n"):
        if "CN" not in line:
            continue
        fields = line.split(",")
        if len(fields) < 2:
            continue
        start, end = fields[0], fields[1]
        target = ipv6 if ":" in start else ipv4
        try:
            target.extend(range_networks(start, end))
        except ValueError:
            continue
    write_txt(SOURCE_DIR / "dbip", ipv4, ipv6)


# Get Data from GeoLite2
def get_data_from_geolite2():
    archive = try_zip(fetch(GEOLITE2_URL))
    if archive is None:
        write_txt(SOURCE_DIR / "geolite2")
        return
    ipv4, ipv6 = [], []
    for name in archive.namelist():
        if name.endswith("GeoLite2-Country-Blocks-IPv4.csv"):
            target = ipv4
        elif name.endswith("GeoLite2-Country-Blocks-IPv6.csv"):
            target = ipv6
        else:
            continue
        for line in archive.read(name).decode("utf-8", errors="replace").split("\n"):
            if "1814991,1814991" in line:
                target.extend(parse_networks([line.split(",")[0]]))
    write_txt(SOURCE_DIR / "geolite2", ipv4, ipv6)


# Get Data from IANA
def get_data_from_iana():
    text = fetch(IANA_URL).decode("utf-8", errors="replace")
    ipv4, ipv6 = [], []
    for line in text.split("\n"):
        if "CN|ipv4" in line:
            fields = line.split("|")
            prefix = 32 - int(round(math.log2(int(fields[4]))))
            ipv4.extend(parse_networks([f"{fields[3]}/{prefix}"]))
        elif "CN|ipv6" in line:
            fields = line.split("|")
            ipv6.extend(parse_networks([f"{fields[3]}/{fields[4]}"]))
    write_txt(SOURCE_DIR / "iana", ipv4, ipv6)


# Get Data from IP2Location
def get_data_from_ip2location():
    archive = try_zip(fetch(IP2LOCATION_URL))
    if archive is None:
        write_txt(SOURCE_DIR / "ip2location")
        return
    ipv4, ipv6 = [], []
    for name in archive.namelist():
        if name.endswith("IP2LOCATION-LITE-DB1.CSV"):
            target = ipv4
        elif name.endswith("IP2LOCATION-LITE-DB1.IPV6.CSV"):
            target = ipv6
        else:
            continue
        for line in archive.read(name).decode("utf-8", errors="replace").split("\n"):
            if '"CN","China"' not in line:
                continue
            fields = line.split(",")
            try:
                start = ipaddress.ip_address(int(fields[0].strip('"')))
                end = ipaddress.ip_address(int(fields[1].strip('"')))
                target.extend(ipaddress.summarize_address_range(start, end))
            except ValueError:
                continue
    # IPv4-mapped IPv6 ranges are dropped, like grep -v '^::ffff:'
    ipv6 = [n for n in ipv6 if not str(n).startswith("::ffff:")]
    write_txt(SOURCE_DIR / "ip2location", ipv4, ipv6)


# Get Data from IPinfo.io
def get_data_from_ipinfoio():
    text = try_gzip(fetch(IPINFOIO_URL)).decode("utf-8", errors="replace")
    ipv4, ipv6 = [], []
    for line in text.split("\n"):
        if "CN" not in line:
            continue
        fields = line.split(",")
        if len(fields) < 2:
            continue
        start, end = fields[0], fields[1]
        target = ipv6 if ":" in start else ipv4
        try:
            target.extend(range_networks(start, end))
        except ValueError:
            continue
    write_txt(SOURCE_DIR / "ipinfoio", ipv4, ipv6)


# Get Data from IPdeny
def get_data_from_ipdeny():
    ipv4, ipv6 = split_lines(fetch(IPDENY_URL).decode("utf-8", errors="replace"))
    write_txt(SOURCE_DIR / "ipdeny", parse_networks(ipv4), parse_networks(ipv6))


# Get Data from IPIPdotNET
def get_data_from_ipipdotnet():
    text = fetch(IPIPDOTNET_URL).decode("utf-8", errors="replace")
    ipv4 = [line for line in text.split("\n") if line and ":" not in line]
    write_txt(SOURCE_DIR / "ipipdotnet", ipv4=parse_networks(ipv4), ipv6_enabled=False)


# Get Data from IPtoASN
def get_data_from_iptoasn():
    ipv4, ipv6 = [], []
    for url, target in zip(IPTOASN_URL, (ipv4, ipv6)):
        text = try_gzip(download(url)).decode("utf-8", errors="replace")
        for line in text.split("\n"):
            if "CN" not in line:
                continue
            fields = line.split("\t")
            if len(fields) < 2:
                continue
            try:
                target.extend(range_networks(fields[0], fields[1]))
            except ValueError:
                continue
    write_txt(SOURCE_DIR / "iptoasn", ipv4, ipv6)


# Get Data from OpenIPDB
def get_data_from_openipdb():
    text = fetch(OPENIPDB_URL).decode("utf-8", errors="replace")
    write_txt(SOURCE_DIR / "openipdb", ipv4=parse_networks(text.split("\n")), ipv6_enabled=False)


# Environment Cleanup: convert changed source txt files to DAT/MMDB
def environment_cleanup():
    status = subprocess.run(
        ["git", "-C", str(ROOT), "status", "-s"], capture_output=True, text=True
    ).stdout
    changed = set()
    for line in status.split("\n"):
        parts = line.split()
        if len(parts) < 2:
            continue
        path = parts[-1]
        for ip_type, txt in (("ipv4", "cn-ipv4.txt"), ("ipv6", "cn-ipv6.txt"), ("all", "cn-all.txt")):
            if path.startswith("sources/") and path.endswith(txt):
                changed.add((path.split("/")[1], ip_type))
    # geoip resolves the "../sources/<name>" paths in templates/*.json from the
    # current directory, so the rendered config runs from ./Temp next to the
    # repo root; TARGET in a template is the placeholder for the source name
    temp_dir = ROOT / "Temp"
    temp_dir.mkdir(exist_ok=True)
    try:
        for source, ip_type in sorted(changed):
            config = (ROOT / "templates" / f"{ip_type}.json").read_text()
            config_file = temp_dir / f"{source}_{ip_type}.json"
            config_file.write_text(config.replace("TARGET", source))
            # geoip exits non-zero on empty input; the original ignores that
            subprocess.run(["geoip", "convert", "-c", str(config_file.resolve())], cwd=temp_dir)
    finally:
        for config_file in temp_dir.glob("*.json"):
            config_file.unlink()
        temp_dir.rmdir()


## Process
def main():
    get_data_from_bgp()
    get_data_from_btpanel()
    get_data_from_dbip()
    get_data_from_geolite2()
    get_data_from_iana()
    get_data_from_ip2location()
    get_data_from_ipdeny()
    get_data_from_ipinfoio()
    get_data_from_ipipdotnet()
    get_data_from_iptoasn()
    get_data_from_openipdb()
    environment_cleanup()


if __name__ == "__main__":
    main()

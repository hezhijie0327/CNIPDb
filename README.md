# CNIPDb

[![License](https://img.shields.io/badge/License-Apache%202.0--Commons%20Clause-blue)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](https://www.python.org/)

## 项目简介

CNIPDb是一个中国IP地址数据库项目，从多个公开数据源收集中国IP地址段，按数据源独立提供TXT、DAT（V2Ray）、MMDB（MaxMind）三种格式的输出，用户可自行选择信任的数据源。开发规范见 [AGENTS.md](AGENTS.md)。

## 特性

- **多数据源**：从BGP、DB-IP、GeoLite2、IANA等多个公开数据源收集IP信息，按源独立发布
- **自动更新**：通过GitHub Actions每日自动更新，确保数据时效性
- **多种格式**：支持TXT、DAT（V2Ray）和MMDB（MaxMind）三种输出格式
- **双协议支持**：同时支持IPv4和IPv6地址段
- **高效处理**：Python 原生合并 CIDR 块（`ipaddress`），并行下载数据源，仅依赖 `geoip` 做格式转换

## 文件下载

所有数据源位于 `sources/<数据源>/`，文件命名统一：`cn-ipv4`（IPv4）、`cn-ipv6`（IPv6）、`cn-all`（IPv4+IPv6合并），格式为 `.txt` / `.dat`（V2Ray）/ `.mmdb`（MaxMind）。BTPanel、IPIPdotNET、OpenIPDB 仅提供 IPv4。按需选择数据源下载：

| 数据源 | IPv4 | IPv6 | IPv4+IPv6 |
|---|---|---|---|
| [BGP](sources/bgp/) | [txt](sources/bgp/cn-ipv4.txt) / [dat](sources/bgp/cn-ipv4.dat) / [mmdb](sources/bgp/cn-ipv4.mmdb) | [txt](sources/bgp/cn-ipv6.txt) / [dat](sources/bgp/cn-ipv6.dat) / [mmdb](sources/bgp/cn-ipv6.mmdb) | [txt](sources/bgp/cn-all.txt) / [dat](sources/bgp/cn-all.dat) / [mmdb](sources/bgp/cn-all.mmdb) |
| [BTPanel](sources/btpanel/) | [txt](sources/btpanel/cn-ipv4.txt) / [dat](sources/btpanel/cn-ipv4.dat) / [mmdb](sources/btpanel/cn-ipv4.mmdb) | - | - |
| [DB-IP](sources/dbip/) | [txt](sources/dbip/cn-ipv4.txt) / [dat](sources/dbip/cn-ipv4.dat) / [mmdb](sources/dbip/cn-ipv4.mmdb) | [txt](sources/dbip/cn-ipv6.txt) / [dat](sources/dbip/cn-ipv6.dat) / [mmdb](sources/dbip/cn-ipv6.mmdb) | [txt](sources/dbip/cn-all.txt) / [dat](sources/dbip/cn-all.dat) / [mmdb](sources/dbip/cn-all.mmdb) |
| [GeoLite2](sources/geolite2/) | [txt](sources/geolite2/cn-ipv4.txt) / [dat](sources/geolite2/cn-ipv4.dat) / [mmdb](sources/geolite2/cn-ipv4.mmdb) | [txt](sources/geolite2/cn-ipv6.txt) / [dat](sources/geolite2/cn-ipv6.dat) / [mmdb](sources/geolite2/cn-ipv6.mmdb) | [txt](sources/geolite2/cn-all.txt) / [dat](sources/geolite2/cn-all.dat) / [mmdb](sources/geolite2/cn-all.mmdb) |
| [IANA](sources/iana/) | [txt](sources/iana/cn-ipv4.txt) / [dat](sources/iana/cn-ipv4.dat) / [mmdb](sources/iana/cn-ipv4.mmdb) | [txt](sources/iana/cn-ipv6.txt) / [dat](sources/iana/cn-ipv6.dat) / [mmdb](sources/iana/cn-ipv6.mmdb) | [txt](sources/iana/cn-all.txt) / [dat](sources/iana/cn-all.dat) / [mmdb](sources/iana/cn-all.mmdb) |
| [IP2Location](sources/ip2location/) | [txt](sources/ip2location/cn-ipv4.txt) / [dat](sources/ip2location/cn-ipv4.dat) / [mmdb](sources/ip2location/cn-ipv4.mmdb) | [txt](sources/ip2location/cn-ipv6.txt) / [dat](sources/ip2location/cn-ipv6.dat) / [mmdb](sources/ip2location/cn-ipv6.mmdb) | [txt](sources/ip2location/cn-all.txt) / [dat](sources/ip2location/cn-all.dat) / [mmdb](sources/ip2location/cn-all.mmdb) |
| [IPdeny](sources/ipdeny/) | [txt](sources/ipdeny/cn-ipv4.txt) / [dat](sources/ipdeny/cn-ipv4.dat) / [mmdb](sources/ipdeny/cn-ipv4.mmdb) | [txt](sources/ipdeny/cn-ipv6.txt) / [dat](sources/ipdeny/cn-ipv6.dat) / [mmdb](sources/ipdeny/cn-ipv6.mmdb) | [txt](sources/ipdeny/cn-all.txt) / [dat](sources/ipdeny/cn-all.dat) / [mmdb](sources/ipdeny/cn-all.mmdb) |
| [IPinfo.io](sources/ipinfoio/) | [txt](sources/ipinfoio/cn-ipv4.txt) / [dat](sources/ipinfoio/cn-ipv4.dat) / [mmdb](sources/ipinfoio/cn-ipv4.mmdb) | [txt](sources/ipinfoio/cn-ipv6.txt) / [dat](sources/ipinfoio/cn-ipv6.dat) / [mmdb](sources/ipinfoio/cn-ipv6.mmdb) | [txt](sources/ipinfoio/cn-all.txt) / [dat](sources/ipinfoio/cn-all.dat) / [mmdb](sources/ipinfoio/cn-all.mmdb) |
| [IPIPdotNET](sources/ipipdotnet/) | [txt](sources/ipipdotnet/cn-ipv4.txt) / [dat](sources/ipipdotnet/cn-ipv4.dat) / [mmdb](sources/ipipdotnet/cn-ipv4.mmdb) | - | - |
| [IPtoASN](sources/iptoasn/) | [txt](sources/iptoasn/cn-ipv4.txt) / [dat](sources/iptoasn/cn-ipv4.dat) / [mmdb](sources/iptoasn/cn-ipv4.mmdb) | [txt](sources/iptoasn/cn-ipv6.txt) / [dat](sources/iptoasn/cn-ipv6.dat) / [mmdb](sources/iptoasn/cn-ipv6.mmdb) | [txt](sources/iptoasn/cn-all.txt) / [dat](sources/iptoasn/cn-all.dat) / [mmdb](sources/iptoasn/cn-all.mmdb) |
| [OpenIPDB](sources/openipdb/) | [txt](sources/openipdb/cn-ipv4.txt) / [dat](sources/openipdb/cn-ipv4.dat) / [mmdb](sources/openipdb/cn-ipv4.mmdb) | - | - |

## 格式说明

### TXT格式

简单的CIDR表示法，每行一个地址段：

```text
1.2.3.0/24
2001:db8::/32
```

### DAT格式

V2Ray兼容的二进制格式：

- 适用于V2Ray、Clash等代理工具
- 文件体积小，加载速度快

### MMDB格式

MaxMind数据库格式：

- 兼容标准MMDB读取器
- 支持多种编程语言的库
- 适用于高并发查询场景

## 本地构建

```bash
git clone https://github.com/hezhijie0327/CNIPDb.git
cd CNIPDb

# 需要 geoip 工具（DAT/MMDB 转换）：go install github.com/Loyalsoldier/geoip@latest
# 令牌源通过环境变量注入（可选，缺省时跳过对应数据源）
GEOLITE2_TOKEN=... IP2LOCATION_TOKEN=... IPINFOIO_TOKEN=... python3 build.py
```

依赖：Python 3.9+（仅标准库）、`geoip`（Go）、`git`。

## 项目结构

```text
CNIPDb/
├── build.py            # 主构建脚本（Python 3.9+，标准库）
├── templates/          # geoip 转换模板（TARGET 为源目录占位符）
│   ├── ipv4.json       # IPv4转换配置
│   ├── ipv6.json       # IPv6转换配置
│   └── all.json        # IPv4+IPv6转换配置
├── sources/            # 各数据源输出（TXT + DAT + MMDB）
└── .github/workflows/  # CI/CD配置
    └── main.yml         # 自动化工作流
```

## License

[Apache License 2.0 with Commons Clause v1.0](LICENSE)

# CNIPDb - 中国IP数据库

## 项目简介

CNIPDb是一个中国IP地址数据库聚合项目，从多个公开数据源收集中国IP地址段，并提供多种格式的输出，适用于不同的应用场景。

### 功能特点

- 🌐 **多数据源聚合**：从BGP、DB-IP、GeoLite2、IANA等多个权威数据源收集IP信息
- 🔄 **自动更新**：通过GitHub Actions每日自动更新，确保数据时效性
- 📦 **多种格式**：支持TXT、DAT（V2Ray）和MMDB（MaxMind）三种输出格式
- 🌍 **双协议支持**：同时支持IPv4和IPv6地址段
- 🚀 **高效处理**：使用专业工具进行CIDR块合并和优化

## 文件下载

### 完整数据集（推荐）

- [`country_ipv4.txt`](cnipdb_zjdb/country_ipv4.txt) - IPv4地址段（纯文本格式）
- [`country_ipv6.txt`](cnipdb_zjdb/country_ipv6.txt) - IPv6地址段（纯文本格式）
- [`country_ipv4_6.txt`](cnipdb_zjdb/country_ipv4_6.txt) - IPv4和IPv6合并地址段

### V2Ray格式

- [`country_ipv4.dat`](cnipdb_zjdb/country_ipv4.dat) - IPv4地址段（V2Ray格式）
- [`country_ipv6.dat`](cnipdb_zjdb/country_ipv6.dat) - IPv6地址段（V2Ray格式）
- [`country_ipv4_6.dat`](cnipdb_zjdb/country_ipv4_6.dat) - IPv4和IPv6合并地址段（V2Ray格式）

### MaxMind格式

- [`country_ipv4.mmdb`](cnipdb_zjdb/country_ipv4.mmdb) - IPv4地址段（MaxMind格式）
- [`country_ipv6.mmdb`](cnipdb_zjdb/country_ipv6.mmdb) - IPv6地址段（MaxMind格式）
- [`country_ipv4_6.mmdb`](cnipdb_zjdb/country_ipv4_6.mmdb) - IPv4和IPv6合并地址段（MaxMind格式）

## 格式说明

### TXT格式

简单的CIDR表示法，每行一个地址段：

```
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

## 项目结构

```
CNIPDb/
├── release.sh          # 主构建脚本
├── script/             # JSON配置模板
│   ├── ipv4.json       # IPv4转换配置
│   ├── ipv6.json       # IPv6转换配置
│   └── ipv4_6.json     # IPv4+IPv6转换配置
├── cnipdb_*/           # 各数据源输出目录
│   ├── country_ipv4.txt    # IPv4地址段
│   ├── country_ipv6.txt    # IPv6地址段
│   ├── country_ipv4_6.txt  # 合并地址段
│   ├── *.dat              # V2Ray格式
│   └── *.mmdb             # MaxMind格式
└── .github/workflows/  # CI/CD配置
    └── main.yml         # 自动化工作流
```

## 许可证

本项目采用Apache License 2.0 with Commons Clause v1.0许可证 - 详见[LICENSE](LICENSE)文件

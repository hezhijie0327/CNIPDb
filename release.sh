#!/bin/bash

# Current Version: 1.8.7

## How to get and use?
# git clone "https://github.com/hezhijie0327/CNIPDb.git" && bash ./CNIPDb/release.sh

## Function
# Environment Preparation
function EnvironmentPreparation() {
    export DEBIAN_FRONTEND="noninteractive"
    export PATH="/root/go/bin:$PATH"
    rm -rf ./Temp && mkdir ./Temp && cd ./Temp
    go install github.com/zhanhb/cidr-merger@latest
    go install github.com/Loyalsoldier/geoip@latest
}
# Environment Cleanup
function EnvironmentCleanup() {
    mkdir -p ../cnipdb
    cat ../cnipdb_*/country_ipv4.txt | sort | uniq | cidr-merger -s > ../cnipdb/country_ipv4.txt
    cat ../cnipdb_*/country_ipv6.txt | sort | uniq | cidr-merger -s > ../cnipdb/country_ipv6.txt
    cat ../cnipdb/country_ipv4.txt ../cnipdb/country_ipv6.txt > ../cnipdb/country_ipv4_6.txt
    GIT_STATUS=($(git status -s | grep "A\|M\|\?" | grep 'country_ipv' | cut -d ' ' -f 3 | grep "txt" | cut -d '/' -f 2-3 | sed 's/cnipdb_//g;s/country_//g;s/.txt//g' | awk "{ print $2 }"))
    for GIT_STATUS_TASK in "${!GIT_STATUS[@]}"; do
        geoip -c "https://raw.githubusercontent.com/hezhijie0327/CNIPDb/source/script/${GIT_STATUS[$GIT_STATUS_TASK]}.json"
    done
    cd .. && rm -rf ./Temp
}
# Get Data from BGP
function GetDataFromBGP() {
    bgp_url=(
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china6.txt"
        "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists/china.txt"
        "https://raw.githubusercontent.com/misakaio/chnroutes2/master/chnroutes.txt"
    )
    for bgp_url_task in "${!bgp_url[@]}"; do
        curl -s --connect-timeout 15 "${bgp_url[$bgp_url_task]}" >> ./bgp_country_ipv4_6.tmp
    done
    bgp_country_ipv4_data=($(cat ./bgp_country_ipv4_6.tmp | grep -v "\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    bgp_country_ipv6_data=($(cat ./bgp_country_ipv4_6.tmp | grep -v "\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    for bgp_country_ipv4_data_task in "${!bgp_country_ipv4_data[@]}"; do
        echo "${bgp_country_ipv4_data[$bgp_country_ipv4_data_task]}" >> ./bgp_country_ipv4.tmp
    done
    for bgp_country_ipv6_data_task in "${!bgp_country_ipv6_data[@]}"; do
        echo "${bgp_country_ipv6_data[$bgp_country_ipv6_data_task]}" >> ./bgp_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_bgp
    cat ./bgp_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_bgp/country_ipv4.txt
    cat ./bgp_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_bgp/country_ipv6.txt
    cat ../cnipdb_bgp/country_ipv4.txt ../cnipdb_bgp/country_ipv6.txt > ../cnipdb_bgp/country_ipv4_6.txt
}
# Get Data from CZ88dotnet
function GetDataFromCZ88dotnet() {
    cz88dotnet_url=(
        "https://raw.githubusercontent.com/metowolf/iplist/master/data/country/CN.txt"
    )
    for cz88dotnet_url_task in "${!cz88dotnet_url[@]}"; do
        curl -s --connect-timeout 15 "${cz88dotnet_url[$cz88dotnet_url_task]}" >> ./cz88dotnet_country_ipv4_6.tmp
    done
    cz88dotnet_country_ipv4_data=($(cat ./cz88dotnet_country_ipv4_6.tmp | sort | uniq | awk "{ print $2 }"))
    for cz88dotnet_country_ipv4_data_task in "${!cz88dotnet_country_ipv4_data[@]}"; do
        echo "${cz88dotnet_country_ipv4_data[$cz88dotnet_country_ipv4_data_task]}" >> ./cz88dotnet_country_ipv4.tmp
    done
    mkdir -p ../cnipdb_cz88dotnet
    cat ./cz88dotnet_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_cz88dotnet/country_ipv4.txt
}
# Get Data from DBIP
function GetDataFromDBIP() {
    dbip_url=(
        "https://download.db-ip.com/free/dbip-country-lite-$(date '+%Y-%m').csv.gz"
    )
    for dbip_url_task in "${!dbip_url[@]}"; do
        curl -s --connect-timeout 15 "${dbip_url[$dbip_url_task]}" >> ./dbip_${dbip_url_task}.csv.gz
        gzip -d ./dbip_${dbip_url_task}.csv.gz && mv ./dbip_${dbip_url_task}.csv ./$(echo ${dbip_url[$dbip_url_task]} | cut -d '/' -f 5 | cut -d '.' -f 1,2)
    done
    dbip_country_ipv4_data=($(cat ./dbip-country-lite-$(date '+%Y-%m').csv | grep 'CN' | cut -d ',' -f 1,2 | tr ',' '-' | grep -v ':' | sort | uniq | awk "{ print $2 }"))
    dbip_country_ipv6_data=($(cat ./dbip-country-lite-$(date '+%Y-%m').csv | grep 'CN' | cut -d ',' -f 1,2 | tr ',' '-' | grep ':' | sort | uniq | awk "{ print $2 }"))
    for dbip_country_ipv4_data_task in "${!dbip_country_ipv4_data[@]}"; do
        echo "${dbip_country_ipv4_data[$dbip_country_ipv4_data_task]}" >> ./dbip_country_ipv4.tmp
    done
    for dbip_country_ipv6_data_task in "${!dbip_country_ipv6_data[@]}"; do
        echo "${dbip_country_ipv6_data[$dbip_country_ipv6_data_task]}" >> ./dbip_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_dbip
    cat ./dbip_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_dbip/country_ipv4.txt
    cat ./dbip_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_dbip/country_ipv6.txt
    cat ../cnipdb_dbip/country_ipv4.txt ../cnipdb_dbip/country_ipv6.txt > ../cnipdb_dbip/country_ipv4_6.txt
}
# Get Data from GeoLite2
function GetDataFromGeoLite2() {
    geolite2_url=(
        "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key={GEOLITE2_TOKEN}&suffix=zip"
    )
    for geolite2_url_task in "${!geolite2_url[@]}"; do
        curl -s --connect-timeout 15 "${geolite2_url[$geolite2_url_task]}" >> ./geolite2_${geolite2_url_task}.zip
        unzip -o -d . ./geolite2_${geolite2_url_task}.zip && rm -rf ./geolite2_${geolite2_url_task}.zip
    done
    geolite2_country_ipv4_data=($(cat ./GeoLite2-Country-CSV_*/GeoLite2-Country-Blocks-IPv4.csv | grep '1814991,1814991' | cut -d ',' -f 1 | sort | uniq | awk "{ print $2 }"))
    geolite2_country_ipv6_data=($(cat ./GeoLite2-Country-CSV_*/GeoLite2-Country-Blocks-IPv6.csv | grep '1814991,1814991' | cut -d ',' -f 1 | sort | uniq | awk "{ print $2 }"))
    for geolite2_country_ipv4_data_task in "${!geolite2_country_ipv4_data[@]}"; do
        echo "${geolite2_country_ipv4_data[$geolite2_country_ipv4_data_task]}" >> ./geolite2_country_ipv4.tmp
    done
    for geolite2_country_ipv6_data_task in "${!geolite2_country_ipv6_data[@]}"; do
        echo "${geolite2_country_ipv6_data[$geolite2_country_ipv6_data_task]}" >> ./geolite2_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_geolite2
    cat ./geolite2_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_geolite2/country_ipv4.txt
    cat ./geolite2_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_geolite2/country_ipv6.txt
    cat ../cnipdb_geolite2/country_ipv4.txt ../cnipdb_geolite2/country_ipv6.txt > ../cnipdb_geolite2/country_ipv4_6.txt
}
# Get Data from IANA
function GetDataFromIANA() {
    iana_url=(
        "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest"
        "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest"
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest"
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
        "https://ftp.apnic.net/stats/iana/delegated-iana-latest"
        "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
        "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest"
        "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest"
        "https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest"
        "https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest"
    )
    for iana_url_task in "${!iana_url[@]}"; do
        curl -s --connect-timeout 15 "${iana_url[$iana_url_task]}" >> ./iana_url.tmp
    done
    iana_country_ipv4_data=($(cat ./iana_url.tmp | grep "CN|ipv4" | sort | uniq | awk "{ print $2 }"))
    iana_country_ipv6_data=($(cat ./iana_url.tmp | grep "CN|ipv6" | sort | uniq | awk "{ print $2 }"))
    for iana_country_ipv4_data_task in "${!iana_country_ipv4_data[@]}"; do
        echo "$(echo $(echo ${iana_country_ipv4_data[$iana_country_ipv4_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_country_ipv4_data[$iana_country_ipv4_data_task]} | awk -F '|' '{ print 32 - log($5) / log(2) }'))" >> ./iana_country_ipv4.tmp
    done
    for iana_country_ipv6_data_task in "${!iana_country_ipv6_data[@]}"; do
        echo "$(echo $(echo ${iana_country_ipv6_data[$iana_country_ipv6_data_task]} | awk -F '|' '{ print $4 }')/$(echo ${iana_country_ipv6_data[$iana_country_ipv6_data_task]} | awk -F '|' '{ print $5 }'))" >> ./iana_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_iana
    cat ./iana_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_iana/country_ipv4.txt
    cat ./iana_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_iana/country_ipv6.txt
    cat ../cnipdb_iana/country_ipv4.txt ../cnipdb_iana/country_ipv6.txt > ../cnipdb_iana/country_ipv4_6.txt
}
# Get Data from IP2Location
function GetDataFromIP2Location() {
    function IPv4NUMConvert() {
        IPv4_ADDR=""
        W=$(echo "obase=10;($IP_NUM / (256^3)) % 256" | bc)
        X=$(echo "obase=10;($IP_NUM / (256^2)) % 256" | bc)
        Y=$(echo "obase=10;($IP_NUM / (256^1)) % 256" | bc)
        Z=$(echo "obase=10;($IP_NUM / (256^0)) % 256" | bc)
        IPv4_ADDR="$W.$X.$Y.$Z"
    }
    function IPv6NUMConvert() {
        IPv6_ADDR=""
        A=$(echo "obase=16;($IP_NUM / (65536^7)) % 65536" | bc)
        B=$(echo "obase=16;($IP_NUM / (65536^6)) % 65536" | bc)
        C=$(echo "obase=16;($IP_NUM / (65536^5)) % 65536" | bc)
        D=$(echo "obase=16;($IP_NUM / (65536^4)) % 65536" | bc)
        E=$(echo "obase=16;($IP_NUM / (65536^3)) % 65536" | bc)
        F=$(echo "obase=16;($IP_NUM / (65536^2)) % 65536" | bc)
        G=$(echo "obase=16;($IP_NUM / (65536^1)) % 65536" | bc)
        H=$(echo "obase=16;($IP_NUM / (65536^0)) % 65536" | bc)
        IPv6_ADDR="$A:$B:$C:$D:$E:$F:$G:$H"
    }
    ip2location_url=(
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DB1LITECSVIPV6"
        "https://www.ip2location.com/download/?token={IP2LOCATION_TOKEN}&file=DB1LITECSV"
    )
    for ip2location_url_task in "${!ip2location_url[@]}"; do
        curl -s --connect-timeout 15 "${ip2location_url[$ip2location_url_task]}" >> ./ip2location_${ip2location_url_task}.zip
        unzip -o -d . ./ip2location_${ip2location_url_task}.zip && rm -rf ./ip2location_${ip2location_url_task}.zip
    done
    ip2location_country_ipv4_data=($(cat ./IP2LOCATION-LITE-DB1.CSV | grep '"CN","China"' | cut -d ',' -f 1,2 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    ip2location_country_ipv6_data=($(cat ./IP2LOCATION-LITE-DB1.IPV6.CSV | grep '"CN","China"' | cut -d ',' -f 1,2 | tr -d '"' | tr ',' '-' | sort | uniq | awk "{ print $2 }"))
    for ip2location_country_ipv4_data_task in "${!ip2location_country_ipv4_data[@]}"; do
        IP_NUM=$(echo "${ip2location_country_ipv4_data[$ip2location_country_ipv4_data_task]}" | cut -d '-' -f 1) && IPv4NUMConvert && IPv4_ADDR_START="${IPv4_ADDR}"
        IP_NUM=$(echo "${ip2location_country_ipv4_data[$ip2location_country_ipv4_data_task]}" | cut -d '-' -f 2) && IPv4NUMConvert && IPv4_ADDR_END="${IPv4_ADDR}"
        echo "${IPv4_ADDR_START}-${IPv4_ADDR_END}" >> ./ip2location_country_ipv4.tmp
    done
    for ip2location_country_ipv6_data_task in "${!ip2location_country_ipv6_data[@]}"; do
        IP_NUM=$(echo "${ip2location_country_ipv6_data[$ip2location_country_ipv6_data_task]}" | cut -d '-' -f 1) && IPv6NUMConvert && IPv6_ADDR_START="${IPv6_ADDR}"
        IP_NUM=$(echo "${ip2location_country_ipv6_data[$ip2location_country_ipv6_data_task]}" | cut -d '-' -f 2) && IPv6NUMConvert && IPv6_ADDR_END="${IPv6_ADDR}"
        echo "${IPv6_ADDR_START}-${IPv6_ADDR_END}" >> ./ip2location_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_ip2location
    cat ./ip2location_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_ip2location/country_ipv4.txt
    cat ./ip2location_country_ipv6.tmp | sort | uniq | cidr-merger -s | grep -v '^::ffff:' > ../cnipdb_ip2location/country_ipv6.txt
    cat ../cnipdb_ip2location/country_ipv4.txt ../cnipdb_ip2location/country_ipv6.txt > ../cnipdb_ip2location/country_ipv4_6.txt
}
# Get Data from IPdeny
function GetDataFromIPdeny() {
    ipdeny_url=(
        "http://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone"
        "http://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone"
    )
    for ipdeny_url_task in "${!ipdeny_url[@]}"; do
        curl -s --connect-timeout 15 "${ipdeny_url[$ipdeny_url_task]}" >> ./ipdeny_country_ipv4_6.tmp
    done
    ipdeny_country_ipv4_data=($(cat ./ipdeny_country_ipv4_6.tmp | grep -v "\:\|\#" | grep '.' | sort | uniq | awk "{ print $2 }"))
    ipdeny_country_ipv6_data=($(cat ./ipdeny_country_ipv4_6.tmp | grep -v "\.\|\#" | grep ':' | sort | uniq | awk "{ print $2 }"))
    for ipdeny_country_ipv4_data_task in "${!ipdeny_country_ipv4_data[@]}"; do
        echo "${ipdeny_country_ipv4_data[$ipdeny_country_ipv4_data_task]}" >> ./ipdeny_country_ipv4.tmp
    done
    for ipdeny_country_ipv6_data_task in "${!ipdeny_country_ipv6_data[@]}"; do
        echo "${ipdeny_country_ipv6_data[$ipdeny_country_ipv6_data_task]}" >> ./ipdeny_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_ipdeny
    cat ./ipdeny_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_ipdeny/country_ipv4.txt
    cat ./ipdeny_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_ipdeny/country_ipv6.txt
    cat ../cnipdb_ipdeny/country_ipv4.txt ../cnipdb_ipdeny/country_ipv6.txt > ../cnipdb_ipdeny/country_ipv4_6.txt
}
# Get Data from IPIPdotNET
function GetDataFromIPIPdotNET() {
    ipipdotnet_url=(
        "https://cdn.ipip.net/17mon/country.zip"
    )
    for ipipdotnet_url_task in "${!ipipdotnet_url[@]}"; do
        curl -s --connect-timeout 15 "${ipipdotnet_url[$ipipdotnet_url_task]}" >> ./ipipdotnet_${ipipdotnet_url_task}.zip
        unzip -o -d . ./ipipdotnet_${ipipdotnet_url_task}.zip && rm -rf ./ipipdotnet_${ipipdotnet_url_task}.zip
    done
    ipipdotnet_country_ipv4_data=($(cat ./country.txt | grep 'CN$' | cut -f 1 | sort | uniq | awk "{ print $2 }"))
    for ipipdotnet_country_ipv4_data_task in "${!ipipdotnet_country_ipv4_data[@]}"; do
        echo "${ipipdotnet_country_ipv4_data[$ipipdotnet_country_ipv4_data_task]}" >> ./ipipdotnet_country_ipv4.tmp
    done
    mkdir -p ../cnipdb_ipipdotnet
    cat ./ipipdotnet_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_ipipdotnet/country_ipv4.txt
}
# Get Data from IPtoASN
function GetDataFromIPtoASN() {
    iptoasn_url=(
        "https://iptoasn.com/data/ip2country-v4.tsv.gz"
        "https://iptoasn.com/data/ip2country-v6.tsv.gz"
    )
    for iptoasn_url_task in "${!iptoasn_url[@]}"; do
        curl -s --connect-timeout 15 "${iptoasn_url[$iptoasn_url_task]}" >> ./iptoasn_${iptoasn_url_task}.tsv.gz
        gzip -d ./iptoasn_${iptoasn_url_task}.tsv.gz && mv ./iptoasn_${iptoasn_url_task}.tsv ./$(echo ${iptoasn_url[$iptoasn_url_task]} | cut -d '/' -f 5 | cut -d '.' -f 1,2)
    done
    iptoasn_country_ipv4_data=($(cat ./ip2country-v4.tsv | grep 'CN' | cut -f 1,2 | tr '\t' '-' | sort | uniq | awk "{ print $2 }"))
    iptoasn_country_ipv6_data=($(cat ./ip2country-v6.tsv | grep 'CN' | cut -f 1,2 | tr '\t' '-' | sort | uniq | awk "{ print $2 }"))
    for iptoasn_country_ipv4_data_task in "${!iptoasn_country_ipv4_data[@]}"; do
        echo "${iptoasn_country_ipv4_data[$iptoasn_country_ipv4_data_task]}" >> ./iptoasn_country_ipv4.tmp
    done
    for iptoasn_country_ipv6_data_task in "${!iptoasn_country_ipv6_data[@]}"; do
        echo "${iptoasn_country_ipv6_data[$iptoasn_country_ipv6_data_task]}" >> ./iptoasn_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_iptoasn
    cat ./iptoasn_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_iptoasn/country_ipv4.txt
    cat ./iptoasn_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_iptoasn/country_ipv6.txt
    cat ../cnipdb_iptoasn/country_ipv4.txt ../cnipdb_iptoasn/country_ipv6.txt > ../cnipdb_iptoasn/country_ipv4_6.txt
}
# Get Data from VXLINK
function GetDataFromVXLINK() {
    vxlink_url=(
        "https://raw.githubusercontent.com/tmplink/IPDB/main/ipv4/cidr/CN.txt"
        "https://raw.githubusercontent.com/tmplink/IPDB/main/ipv6/cidr/CN.txt"
    )
    for vxlink_url_task in "${!vxlink_url[@]}"; do
        curl -s --connect-timeout 15 "${vxlink_url[$vxlink_url_task]}" >> ./vxlink_country_ipv4_6.tmp
    done
    vxlink_country_ipv4_data=($(cat ./vxlink_country_ipv4_6.tmp | grep -v "\:" | grep '.' | sort | uniq | awk "{ print $2 }"))
    vxlink_country_ipv6_data=($(cat ./vxlink_country_ipv4_6.tmp | grep -v "\." | grep ':' | sort | uniq | awk "{ print $2 }"))
    for vxlink_country_ipv4_data_task in "${!vxlink_country_ipv4_data[@]}"; do
        echo "${vxlink_country_ipv4_data[$vxlink_country_ipv4_data_task]}" >> ./vxlink_country_ipv4.tmp
    done
    for vxlink_country_ipv6_data_task in "${!vxlink_country_ipv6_data[@]}"; do
        echo "${vxlink_country_ipv6_data[$vxlink_country_ipv6_data_task]}" >> ./vxlink_country_ipv6.tmp
    done
    mkdir -p ../cnipdb_vxlink
    cat ./vxlink_country_ipv4.tmp | sort | uniq | cidr-merger -s > ../cnipdb_vxlink/country_ipv4.txt
    cat ./vxlink_country_ipv6.tmp | sort | uniq | cidr-merger -s > ../cnipdb_vxlink/country_ipv6.txt
    cat ../cnipdb_vxlink/country_ipv4.txt ../cnipdb_vxlink/country_ipv6.txt > ../cnipdb_vxlink/country_ipv4_6.txt
}

## Process
# Call EnvironmentPreparation
EnvironmentPreparation
# Call GetDataFromBGP
GetDataFromBGP
# Call GetDataFromCZ88dotnet
#GetDataFromCZ88dotnet
# Call GetDataFromDBIP
#GetDataFromDBIP
# Call GetDataFromGeoLite2
#GetDataFromGeoLite2
# Call GetDataFromIANA
#GetDataFromIANA
# Call GetDataFromIP2Location
#GetDataFromIP2Location
# Cal GetDataFromIPdeny
#GetDataFromIPdeny
# Call GetDataFromIPIPdotNET
#GetDataFromIPIPdotNET
# Call GetDataFromIPtoASN
#GetDataFromIPtoASN
# Call GetDataFromVXLINK
#GetDataFromVXLINK
# Call EnvironmentCleanup
EnvironmentCleanup

# Update IP2Location
## Download
1. Go to kube-0 server and change your working directory to "/root/ip2location".
2. Download new version of *ip2location* with below command:
   `wget "https://www.ip2location.com/download?code=DB4BIN" --load-cookies=cookies.txt --output-document=DB4-IP-COUNTRY-REGION-CITY-ISP.BIN.ZIP`
   *NOTE* Before starting download process be sure file "DB4-IP-COUNTRY-REGION-CITY-ISP.BIN.ZIP" DO NOT EXIST.
## Preparation:
1. Unzip downloaded file:
   `unzip DB4-IP-COUNTRY-REGION-CITY-ISP.BIN.ZIP`
2. Calculate "IP-COUNTRY-REGION-CITY-ISP.BIN" file md5 check sum and store it in "IP-COUNTRY-REGION-CITY-ISP.BIN.md5" file.
   `md5sum IP-COUNTRY-REGION-CITY-ISP.BIN > IP-COUNTRY-REGION-CITY-ISP.BIN.md5`
3. zip "IP-COUNTRY-REGION-CITY-ISP.BIN" and store it in "IP-COUNTRY-REGION-CITY-ISP.BIN.gz" file.
   `gzip IP-COUNTRY-REGION-CITY-ISP.BIN`
## Transfer
1. transfer both files (gzip IP-COUNTRY-REGION-CITY-ISP.BIN.gz and gzip IP-COUNTRY-REGION-CITY-ISP.BIN.md5) to /cephfs/legasy/statics directory.

## Done.

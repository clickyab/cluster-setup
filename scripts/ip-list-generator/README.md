# IP List Generator:

## Fetch ip lists from mikrotik:
`/ip dhcp-server lease print file=lease.txt`
## Donwload lease.txt file.

## Human readable ip list generator from mikrotik ip lease list.
`usage: ./ip-list-generator.sh <input-file> <output-file>`

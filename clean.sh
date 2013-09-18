#!/bin/bash
cd datafeed
sort -t ',' bcfeed_mtgoxUSD_1min.csv -o sorted && rm bcfeed_mtgoxUSD_1min.csv && mv sorted bcfeed_mtgoxUSD_1min.csv
cd ..

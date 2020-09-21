#!/bin/bash

#
# laptops.sh
#

#
## Linux
#

while read -r URL ; do
	curl -s "$URL"
	#curl -s https://system76.com/laptops/addw2/configure
done < <(curl -s https://system76.com/laptops \
	| grep "<a href=\"/laptops/" \
	| perl -pe 's/</\n</g;s/>/>\n/g' \
	| grep "<a href=\"/laptops/" \
	| perl -pe 's/<a href="//g;s/" .*//g' \
	| grep "configure" \
	| sort -u)

#https://www.tuxedocomputers.com/en/Linux-Hardware/Linux-Notebooks.tuxedo

#https://www.dell.com/en-ca/shop/scc/sc/laptops
#https://www.dell.com/en-ca/work/shop/scc/sc/laptops

#https://www.lenovo.com/ca/en/laptops/c/LAPTOPS

#https://slimbook.es/en/store/essential

#
##Brands
#

#https://www.amd.com/en/shop/ca/Laptops

#
##Retail
#

#https://www.costco.ca/laptops.html

#https://www.microsoft.com/en-ca/store/collections/laptops

#https://www.amazon.ca/b/?_encoding=UTF8&node=677252011&bbn=667823011&ref_=Oct_s9_apbd_odnav_hd_bw_b2cl5lT_0&pf_rd_r=Q9KETVTQT5734RTQTR5W&pf_rd_p=3e9d1eb9-c4b2-5d47-afdd-d1b6f48a1cdc&pf_rd_s=merchandised-search-11&pf_rd_t=BROWSE&pf_rd_i=2404990011

#https://www.newegg.ca/Laptops-Notebooks/SubCategory/ID-32?Tid=6741

#https://www.staples.ca/products/2974877-en-lenovo-ideapad-flex-5-81x2000ucf-14-inch-touch-screen-2-in-1-27-ghz-amd-ryzen-3-4300u-256-gb-ssd-8-gb-ddr4-windows-10-home

#https://www.bestbuy.ca/en-ca/category/laptops/36711?icmp=computing_evergreen_laptops_and_macbooks_category_detail_category_icon_shopby_windows_laptops

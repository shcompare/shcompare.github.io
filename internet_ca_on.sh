#!/bin/bash

#
# internet.sh
#

#randomly chosen

set -e
trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR
TMP="$(mktemp)"
function finalize {
	rm "$TMP"
}
trap finalize EXIT

echo "["
{
#bell
while read -r L ; do
	echo -e "{\n  \"isp\":\"bell\","
	C=1;
	while read -r V ; do
		if [[ "$V" =~ .*Gbps ]] ; then
			V="$(echo "$V" | perl -pe 's/\.([0-9]) Gbps/${1}00/g;
				s/"([0-9]) Gbps/${1}000/g')"
		fi
		if [ "$C" -eq 1 ] ; then
			echo "  \"down (Mbps)\":\"$V\","
		elif [ "$C" -eq 2 ] ; then
			echo "  \"up (Mbps)\":\"$V\","
		elif [ "$C" -eq 3 ] ; then
			echo "  \"cap (GB)\":\"$V\","
		elif [ "$C" -eq 4 ] ; then
			echo "  \"price (CAD)\":$V"
		fi
		C=$((C+1))
	done < <(echo "$L" | perl -pe 's/(<span|<div|<a )/\n$1/g' \
		| grep -P "rsx-price-brs\"|rsx-block rsx-h4" \
		| perl -pe 's/<sup>(\.\d+)<\/sup>/$1/g;
			s/<sup[^<>]*>[^<>]+<\/sup>//g;
			s/<[^<>]+>//g;
			s/ Mbps| GB//g')
	echo "}"
done < <(curl -s "https://www.bell.ca/Bell_Internet/Internet_access" \
	| perl -0pe 's/[\s\n\r\t ]+/ /g;
		s/(<div id="product_|<style)/\n$1/g' \
	| grep "<div id=\"product_" ) 

#rogers
curl -s 'https://www.rogers.com/web/totes/browsebuy/sai/v2/getSAIOffers' \
	--compressed -H 'Content-Type: application/json' \
	--data-raw '{"postalCode":"L6R2K7","customerType":"N","accountNumber":"","province":"on","samKey":"2330001388497","language":"en"}' \
	| jq ".en.bundleOffers[].internetOffers[] | {isp:\"rogers\", \"down (Mbps)\":((.speed.download | tostring) + \" \" + .speed.downloadUnit), \"up (Mbps)\":((.speed.upload|tostring) + \" \" + .speed.uploadUnit), \"price (CAD)\":.offerPrice.price, \"cap (GB)\":.usageAllowance}" \
	| perl -pe 's/"UNLTD"/"Unlimited"/g;
		s/("[0-9]) Gbps/${1}000/g;
		s/ Mbps//g'

#teksavvy
#"L6R2K7"
curl -s 'https://package.api.teksavvy.com/api/v1/External/Qualification/Packages?classificationID=1&uaid=C7FC6861-7189-2B8E-4FC7-20FD8B6C5F76' \
	| jq ".[] | select(.serviceType==\"Internet\") | select(.qualifies==true) | .packages[] | {isp:\"teksavvy\", \"cap (GB)\":.bandwidth, \"down (Mbps)\":.download, \"up (Mbps)\":.upload, \"price (CAD)\":.price}" \
	| perl -pe 's/null/"Unlimited"/g'

#start
URL="https://www.start.ca/services/high-speed-internet"

#vmedia
URL="https://www.vmedia.ca/en/internet"

#execulink
URL="https://www.execulink.ca/residential/internet/"
curl -s "$URL" > /dev/null

#primus
while read -r URL ; do
	curl -s "$URL" > "$TMP"
	echo -e "{\n  \"isp\":\"primus\","
	echo "  \"cap (GB)\":\"Unlimited\","
	grep 'class="promo"' "$TMP" | perl -pe 's/.*\$/  "price (CAD)":/g;s/<.*/,/g'
	C=1;
	while read -r V ; do
		if [ "$C" -eq 1 ] ; then
			echo "  \"down (Mbps)\":\"$V\","
		elif [ "$C" -eq 2 ] ; then
			echo "  \"up (Mbps)\":\"$V\""
		fi
		C=$((C+1))
	done < <(grep "load speed" "$TMP" | perl -pe 's/(bps) .*/$1/g;
		s/.* to //g;
		s/ Mbps//g
		')
	echo "}"
done < <(curl -s 'https://primus.ca/ont_en/internet.html' \
	-H 'Cookie: PRIMADDR=5f6647dd75075; PRIMSVC=PROVINCE%3DON%3AHPREGION%3D%3ATVBREGION%3D%3APC%3DL6R2K7%3ACITY%3D%3APRODUCT%3Dinternet%3AHOMEPHONE%3D%3ABUNDLE%3D%3ADSL%3Db-15.0-10.0%2Cb-25.0-10.0%2Cb-50.0-10.0%2Cr-75.0-10.0%2Cr-150.0-15.0%2Cr-300.0-20.0%3ADHPCARRIER%3D%3AVOIP%3D%3AIPL-PORTABLE%3D%3AMIGRATE%3D%3ALOCALE%3Dont_en%3AIPL-AVAILABLE%3D%3ADSLREGION%3DDSL-ONT%3ADBUNDLE%3D%3ATHP-NEW%3D%3ATHP-PORTABLE%3D%3AHP-CARRIER%3D%3AILEC%3D%3AVERS%3D2.0' \
	| grep "/internet/" \
	| perl -pe 's/(html)".*/$1/g;s/.*"//g' \
	| grep "html")
} | perl -pe 's/\}/},/g'
echo "{}]"

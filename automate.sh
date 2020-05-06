#!/bin/sh
usage () {
	{
		echo "Usage: $0"
		echo "       --resource-group rg"
		echo "       --active-region ar"
		echo "       --standby-region sr"
	} >&2
}
color () {
	{
		[ -t 2 ] && { tput setaf $1; tput bold; }
		shift
		echo "$@"
		[ -t 2 ] && tput sgr0
	} >&2
}
error () {
	color 1 "[error: $@]"
	usage
	exit 1
}
green () {
	color 2 "$@"
}
orange () {
	color 3 "$@"
}

# parse flags
while [ "$#" -gt 0 ]; do
	case $1 in
		--resource-group)
			rg="$2"; shift
			;;
		--active-region)
			ar="$2"; shift
			;;
		--standby-region)
			sr="$2"; shift
			;;
		--*)
			error "unknown option: $1" >&2
			;;
	esac
	shift
done

[ -z "$rg" ] && error "resource-group not set"
[ -z "$ar" ] && error "active-region not set"
[ -z "$sr" ] && error "standby-region not set"
{
	green  "Deploying:"
	orange "    rg=$rg"
	orange "    ar=$ar"
	orange "    sr=$sr"
} >&2

az () {
	echo "az $@"
}

for region in "$ar" "$sr"; do
	az appservice plan create \
		--name "$region-papillonPlan" \
		--resource-group "$rg" \
		--location "$region"
		--sku free

	az webapp create \
		--plan "$region-papillonPlan" \
		--name "$region-papillonApp" \
		--resource-group "$rg" \
		--runtime "PHP|7.4" \
		--deployment-source-url "https://github.com/alexknipper/papillon-azure.git"
done

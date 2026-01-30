#! /usr/bin/env bash

set -euo pipefail
shopt -s failglob
ARCHIVE="$1"

if [[ -z "$ARCHIVE" ]]; then
	echo "Usage: $0 </path/to/ide.tar.gz>"
	exit 1
fi

INFO_JSON="$(tar -xOzf "$ARCHIVE" --wildcards "*-*/product-info.json")"
getJson() { jq --raw-output "$1" <<< "$INFO_JSON"; }

PLUGIN_API_BASE="https://plugins.jetbrains.com/api/search/updates/compatible?build=$(getJson .productCode)-$(getJson .buildNumber)"

echo "Checking marketplace availability of bundled plugins for $(getJson .name) $(getJson .version) ($(getJson .buildNumber))..."
echo

# shellcheck disable=SC2016
getJson '.bundledPlugins[]' \
  | grep -v -e 'javaee' -e 'spring' -e 'Lombook' -e 'colorscheme' \
  | split -l 10 --filter="sd '^(.+)$' '&pluginXmlId=\$1' | xargs -I {} -- xh -v GET '$PLUGIN_API_BASE{}'"
#  | split -l 10 --filter="xh -v $PLUGIN_API_BASE"'$(sd "^(.+)$" "&pluginXmlId=\$1")'


#  | parallel --pipe --block 10 --line-buffer "xh -v \"$PLUGIN_API_BASE\$(sd '^(.+)$' '&pluginXmlId=\$1')\""

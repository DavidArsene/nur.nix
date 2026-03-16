#! /usr/bin/env bash

set -euo pipefail
shopt -s failglob
INPUT="$1"

if [[ -z "$INPUT" ]]; then
	echo "Usage: $0 </path/to/ide.tar.gz> or </path/to/ide/dir>"
	exit 1
fi

if [[ -d "$INPUT" ]]; then
	INFO_JSON="$(cat "$INPUT/product-info.json")"
else
	INFO_JSON="$(tar -xOzf "$INPUT" --wildcards "*-*/product-info.json")"
fi
getJson() { jq --raw-output "$1" <<< "$INFO_JSON"; }

echo "All bundled plugins are:"
declare -A "LOCATIONS=($(getJson 'reduce
	(.layout[] | select(.kind == "plugin")) as $it
	({};
	. + { (
		$it.name
	): (
		$it.classPath[0] | sub(
			"plugins/(?<dir>.*)/lib/.*jar"; "\(.dir)"
		)
	) })
	| to_entries
	| map("[\(.key)]=\(.value)")
	[]
' | tee /dev/stderr))"

NAME="$(getJson .name)"
VERSION="$(getJson .version)"
PC="$(getJson .productCode)"
BN="$(getJson .buildNumber)"

echo
echo "Checking marketplace availability of bundled plugins for $NAME $VERSION ($PC-$BN)..."

BUNDLED_PLUGINS=$(getJson '.bundledPlugins[]' | grep -v -e 'javaee' -e 'spring' -e 'Lombook' -e 'colorscheme')

RESPONSE=$(xh "https://plugins.jetbrains.com/api/search/compatibleUpdates" \
	build="$PC-$BN" \
	pluginXMLIds:="[$(sd '^(.*)$' '"$1",' <<< "$BUNDLED_PLUGINS")0]")
# '0' is added to eat the trailing comma

echo "The following plugins were not included in the response:"
echo
INCLUDED="$(jq --raw-output '.[] | .pluginXmlId' <<< "$RESPONSE")"

while IFS= read -r plugin; do
	grep -q "$plugin" <<< "$INCLUDED" || echo "$plugin (plugins/${LOCATIONS["$plugin"]})"
done <<< "$BUNDLED_PLUGINS"

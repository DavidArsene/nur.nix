#! /usr/bin/env bash

set -euo pipefail
shopt -s failglob

# PRODUCTS=(DG) # RD)
# NB: idea should be first for best compatibility
PRODUCTS_MAVEN=(idea clion) # studio)
 # pycharm: only dataWrangler and pyscript + customization
 # datagrip: not on maven, has one (1) plugin i don't remember
 # android-studio: still on 253, TODO
 # riderRD: different artifact name on maven, also very different from other IJPLs.
 # no new plugins: webstorm, rustrover
 # idc about: goland, phpstorm, rubymine
 # clion bin:
 # - helpers
 # - ${(linux/amd64)? if multiplatform zip} + /native-helper/intellij-rust-native-helper
 # - lldb/helpers

# MAVEN_BASE='https://www.jetbrains.com/intellij-repository/snapshots/com/jetbrains/intellij'
MAVEN_BASE='https://www.jetbrains.com/intellij-repository/releases/com/jetbrains/intellij'

BLACKLIST=(
	'localization-*'
	'cwm-plugin'
	'platform-daemon-plugin'
	'fullLine'
	'javaee-*'
	'*-sharedIndexes-bundled'
	# 'android-ndk' # !
	'lib/*'
)

ESSENTIAL=(
	'com.intellij.java'
	'com.intellij.modules.json'
	'intellij.properties' # needed by Groovy
)

INFO_JSON=
BN_IDEA=
mkdir -p /tmp/JottedBrains
cd /tmp/JottedBrains || exit 1

black_light='\e[1;30m'
# red_light='\e[1;31m'
green_light='\e[1;32m'
yellow_light='\e[1;33m'
blue_light='\e[1;34m'
reset='\e[0m'

getJson() { yq "$@" <<< "$INFO_JSON"; }
eko() { echo -e "\n$*\n"; }

resolve_latest_archive() {
	local code="$1" version

	if [[ $code == "studio" ]]; then
		local url="https://jb.gg/android-studio-releases-list.json"
		xh -F "$url" | yq '
first(
	.content.item.[] | select(.channel == "Release" or .channel == "Patch")
).download.[].link | select(endswith(".zip"))
	'
	else
		# local url="https://data.services.jetbrains.com/products/releases?code=$1&latest=true" # &release=true
		# xh "$url" | jq -r '.[].[].downloads.windowsZip.link'

		local url="$MAVEN_BASE/$code/$code/maven-metadata.xml"
		version="$(xh -F "$url" | yq -p xml .metadata.versioning.latest)"

		version="${version%-CANDIDATE}"
		version="${version%-SNAPSHOT}"

		echo "$MAVEN_BASE/$code/$code/$version/$code-$version.zip"
	fi
}

should_keep() {
	local name="$1" dir="$2" p

	if [[ -d "plugins/$dir" ]]; then
		echo -e "${yellow_light}Already have $name in $dir$reset"
		return 1
	fi

	for p in "${BLACKLIST[@]}"; do
		# shellcheck disable=SC2053
		if [[ "$name" == $p || "$dir" == $p ]]; then
			echo -e "${black_light}Blacklisted: $name$reset"
			return 1
		fi
	done
}

for CODE in "${PRODUCTS_MAVEN[@]}"; do
	eko "${blue_light}Checking $CODE...$reset"
	URL="$(resolve_latest_archive "$CODE")"
	ARCHIVE="$(basename "$URL")"

	if [[ ! -f "$ARCHIVE" ]]; then
		eko "Downloading $URL"
		xh --download --follow "$URL" -o "$ARCHIVE"
	else
		eko "Using cached $ARCHIVE"
	fi

	[[ "$CODE" == "studio" ]] && ROOT="android-studio/" || ROOT=""
	INFO_JSON="$(7zz x "$ARCHIVE" -so "${ROOT}product-info.json")"

	# NOTE: jq uses ";" as the separator for function args, while yq uses ","
	# Similarly, changed the regex reference syntax from "\(.name)" to "${name}"
	# shellcheck disable=SC2016
	declare -A "LOCATIONS=($(
		getJson '
.layout[] | select(.kind == "plugin")
| (.classPath[0] | sub("plugins/(?<dir>.*)/lib/.*jar", "${dir}")) as $dir
| "[\(.name)]=\"\($dir)\""
'
	))"

	[[ -z "$BN_IDEA" ]] && BN_IDEA="$(getJson .buildNumber)"
	INCLUDED="$(
		xh "https://plugins.jetbrains.com/api/search/compatibleUpdates" \
			build="IU-$BN_IDEA" \
			pluginXMLIds:="$(getJson -o json -I 0 '.bundledPlugins')" \
		\
			| yq -o ini '.[].pluginXmlId'
	)"

	while IFS= read -r plugin; do
		if grep -Fqx "$plugin" <<< "$INCLUDED" && ! grep -Fqx "$plugin" <<< "$ESSENTIAL"; then
			continue
		fi

		DIR="${LOCATIONS["$plugin"]:-}"
		[[ -z "$DIR" ]] && continue

		should_keep "$plugin" "$DIR" || continue

		echo -e "${green_light}Extracting: $plugin -> $DIR$reset"
		7zz x "$ARCHIVE" "${ROOT}plugins/$DIR" -bso0
	done <<< "$(getJson -o ini '.bundledPlugins[]')"

	# mv plugins "$CODE-plugins" 2>/dev/null || eko "${red_light}Got no plugins from $CODE$reset"
done

eko
fd aarch64
fd darwin
fd win

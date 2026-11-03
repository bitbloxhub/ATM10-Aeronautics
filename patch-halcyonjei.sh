#!/usr/bin/env bash
set -euo pipefail

mods_dir="${1:?Usage: patch-halcyonjei.sh <instance-minecraft/mods>}"
jar="$mods_dir/HalcyonJEI-21.1.0.jar"
metadata='META-INF/neoforge.mods.toml'

if [[ ! -f "$jar" ]]; then
	printf 'HalcyonJEI jar not found: %s\n' "$jar" >&2
	exit 1
fi

current_id="$(unzip -p "$jar" "$metadata" | sed -n 's/^[[:space:]]*modId = "\([^"]*\)"[[:space:]]*$/\1/p' | grep -E '^(datanessence|halcyon)$' | head -n 1 || true)"
if [[ "$current_id" == halcyon ]]; then
	printf 'HalcyonJEI already targets mod ID halcyon\n'
	exit 0
fi
if [[ "$current_id" != datanessence ]]; then
	printf 'Expected datanessence dependency not found in %s\n' "$jar" >&2
	exit 1
fi

backup="$jar.upstream"
if [[ ! -e "$backup" ]]; then
	cp -- "$jar" "$backup"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/META-INF"
unzip -p "$jar" "$metadata" \
	| sed 's/modId = "datanessence"/modId = "halcyon"/' > "$tmp/$metadata"
zip -q "$jar" -d "$metadata"
(cd "$tmp" && zip -q "$jar" "$metadata")

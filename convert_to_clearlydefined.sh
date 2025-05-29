#!/bin/bash

# Usage: ./convert_to_clearlydefined.sh input.txt
# Each line in input.txt should be a URL (one per line)
# The output will be written to clearly.txt

input="$1"
output="output.txt"

# Clear the output file at the start
> "$output"

while IFS= read -r url; do
    if [[ "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/commit/([a-f0-9]+) ]]; then
        org="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
        commit="${BASH_REMATCH[3]}"
        coords="git/github/$org/$repo/$commit"
        tool="source"
        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
        echo >> "$output"
    elif [[ "$url" =~ ^https://www\.npmjs\.com/package/([^/]+)/v/([^/]+) ]]; then
        package="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        coords="npm/npmjs/-/$package/$version"
        tool="package"
        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
        echo >> "$output"
    elif [[ "$url" =~ ^https://pypi\.org/project/([^/]+)/([^/]+)/? ]]; then
        package="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        coords="pypi/pypi/-/$package/$version"
        tool="package"
        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
        echo >> "$output"
#    elif [[ "$url" =~ ^https://mvnrepository\.com/artifact/([^/]+)/([^/]+)/([^/]+) ]]; then
#        group="${BASH_REMATCH[1]}"
#        artifact="${BASH_REMATCH[2]}"
#        version="${BASH_REMATCH[3]}"
#        coords="maven/mavencentral/$group/$artifact/$version"
#        tool="source"
#        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
#        echo >> "$output"
elif [[ "$url" =~ ^https://search\.maven\.org/artifact/([^/]+)/([^/]+)/([^/]+)/.*$ ]]; then
    group="${BASH_REMATCH[1]}"
    artifact="${BASH_REMATCH[2]}"
    version="${BASH_REMATCH[3]}"
    coords="maven/mavencentral/$group/$artifact/$version"
    tool="source"
    echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
    echo >> "$output"
    elif [[ "$url" =~ ^https://www\.nuget\.org/packages/([^/]+)/([^/]+) ]]; then
        id="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        if [[ "$id" == *.* ]]; then
            org="${id%%.*}"
            pkg="${id#*.}"
            coords="nuget/nuget/-/$org/$pkg/$version"
        else
            coords="nuget/nuget/-/$id/$version"
        fi
        tool="package"
        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
        echo >> "$output"
    elif [[ "$url" =~ ^https://rubygems\.org/gems/([^/]+)/versions/([^/]+) ]]; then
        gem="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        coords="gem/-/$gem/$version"
        tool="package"
        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
        echo >> "$output"
elif [[ "$url" =~ ^https://sources\.debian\.org/src/([^/]+)/([^/]+)/?$ ]]; then
    pkg="${BASH_REMATCH[1]}"
    version="${BASH_REMATCH[2]}"
    coords="deb/debian/-/$pkg/$version"
    tool="source"
    echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
    echo >> "$output"
    elif [[ "$url" =~ ^https://pkg\.go\.dev/([^@]+)@([^/]+)$ ]]; then
        module="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        coords="$module@$version"
        tool="source"
        echo "curl -X POST \"https://api.clearlydefined.io/harvest\" -H \"accept: */*\" -H \"Content-Type: application/json\" -d \"[{\\\"tool\\\":\\\"$tool\\\",\\\"coordinates\\\":\\\"$coords\\\"}]\"" >> "$output"
        echo >> "$output"
    else
        echo "# Unknown or unsupported URL format: $url" >> "$output"
        echo >> "$output"
    fi
done < "$input"

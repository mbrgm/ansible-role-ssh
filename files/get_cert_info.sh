#!/bin/bash
set -eou pipefail
IFS=$'\n\t'

SECONDS_PER_HOUR=3600
HOURS_PER_DAY=24

cert_file="$1"

cert_info=$(ssh-keygen -Lf "$cert_file")

signing_ca=$(
    echo "$cert_info" \
    | grep -P '^\s*Signing CA:' \
    | sed 's/\s*Signing CA: //')

signing_ca_fingerprint=$(
    echo "$signing_ca" \
    | cut -d ' ' -f2)

expiration_timestamp=$( \
    echo "$cert_info" \
    | grep -P '^\s*Valid:' \
    | sed 's/\s*Valid: from.*to //' \
    | date +%s -f -)

now_timestamp=$(date +%s)
remaining_seconds=$(( $expiration_timestamp - $now_timestamp ))
remaining_days=$(( $remaining_seconds / $SECONDS_PER_HOUR / $HOURS_PER_DAY ))

cat <<EOF
{
    "remaining_days": ${remaining_days},
    "signing_ca_fingerprint": "${signing_ca_fingerprint}"
}
EOF

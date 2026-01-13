#!/bin/bash

# Configuration - Customize these
CONTAINERS="paperless_db_1 paperless_broker_1 paperless_webserver_1 watchtower paperless_tika_1 paperless_gotenberg_1"
OUTPUT_FILE="/tmp/DockerStats4PRTG.xml"

# Make sure output file exist for processing
touch $OUTPUT_FILE

# Function to generate XML results for one container
generate_xml() {
  local NAME="$1" CPU="$2" MEM="$3" NETIO="$4"
  [[ -z "$NAME" || "$NAME" == "NAME" ]] && return

  # CPU
  local CPU_VAL="${CPU%%%}"
  CPU_VAL="${CPU_VAL//,/}"
  CPU_VAL="${CPU_VAL:-0}"

  # Memory usage only (before /)
  local MEM_USAGE="${MEM%%/*}"
  local MEM_NUM=$(echo "$MEM_USAGE" | sed 's/[^0-9.]//g')
  local MEM_UNIT=$(echo "$MEM_USAGE" | sed -n 's/.*\([KMG]iB\).*/\1/p')

  case "${MEM_UNIT:-B}" in
    GiB) local MEM_BYTES=$(awk "BEGIN {printf \"%d\", $MEM_NUM * 1073741824}") ;;
    MiB) local MEM_BYTES=$(awk "BEGIN {printf \"%d\", $MEM_NUM * 1048576}") ;;
    KiB) local MEM_BYTES=$(awk "BEGIN {printf \"%d\", $MEM_NUM * 1024}") ;;
    *)   local MEM_BYTES=0 ;;
  esac

  # Net RX/TX simple split
  local RX="${NETIO%%/*}"
  local TX="${NETIO#*/}"
  local RX_NUM=$(echo "$RX" | sed 's/[^0-9.]//g')
  local TX_NUM=$(echo "$TX" | sed 's/[^0-9.]//g')
  local RX_UNIT=$(echo "$RX" | grep -o '[KMGB]' | tail -1)
  local TX_UNIT=$(echo "$TX" | grep -o '[KMGB]' | tail -1)

  RX_BYTES=0; TX_BYTES=0
  [[ "$RX_UNIT" == "G" ]] && RX_BYTES=$(awk "BEGIN {printf \"%d\", $RX_NUM * 1073741824}")
  [[ "$RX_UNIT" == "M" ]] && RX_BYTES=$(awk "BEGIN {printf \"%d\", $RX_NUM * 1048576}")
  [[ "$TX_UNIT" == "G" ]] && TX_BYTES=$(awk "BEGIN {printf \"%d\", $TX_NUM * 1073741824}")
  [[ "$TX_UNIT" == "M" ]] && TX_BYTES=$(awk "BEGIN {printf \"%d\", $TX_NUM * 1048576}")

# Create XML result
  cat << EOF
  <result>
    <channel>$(echo "$NAME" | tr -C '[:alnum:]' '_')_CPU</channel>
    <unit>Percent</unit>
    <value>$CPU_VAL</value>
  </result>
  <result>
    <channel>$(echo "$NAME" | tr -C '[:alnum:]' '_')_Mem</channel>
    <unit>BytesMemory</unit>
    <value>$MEM_BYTES</value>
  </result>
  <result>
    <channel>$(echo "$NAME" | tr -C '[:alnum:]' '_')_NetRX</channel>
    <unit>BytesBandwidth</unit>
    <value>${RX_BYTES:-0}</value>
  </result>
  <result>
    <channel>$(echo "$NAME" | tr -C '[:alnum:]' '_')_NetTX</channel>
    <unit>BytesBandwidth</unit>
    <value>${TX_BYTES:-0}</value>
  </result>
EOF
}

# Collect stats
STATS=$(docker stats --no-stream --no-trunc \
  --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" \
  $CONTAINERS 2>/dev/null | tail -n +2)

# Create error file if feedback is empty
if [[ -z "$STATS" ]]; then
  cat > "$OUTPUT_FILE" << 'EOF'
<?xml version="1.0" encoding="Windows-1252"?>
<prtg>
  <error>1</error>
  <text>No data</text>
</prtg>
EOF
  exit 1
fi

# Build final XML
{
  echo '<?xml version="1.0" encoding="Windows-1252"?>'
  echo '<prtg>'
  echo "$STATS" | while IFS=$'\t' read -r NAME CPU MEM NETIO; do
    generate_xml "$NAME" "$CPU" "$MEM" "$NETIO"
  done
  echo '</prtg>'
} > "$OUTPUT_FILE"

# Export it for HTTP push to PRTG
cat "$OUTPUT_FILE"

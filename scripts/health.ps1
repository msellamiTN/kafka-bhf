param(
  [string]$Container = "kafka",
  [string]$Bootstrap = "kafka:9093"
)

$cmd = "if command -v kafka-broker-api-versions.sh >/dev/null 2>&1; then kafka-broker-api-versions.sh --bootstrap-server $Bootstrap; elif command -v kafka-broker-api-versions >/dev/null 2>&1; then kafka-broker-api-versions --bootstrap-server $Bootstrap; else echo 'No kafka-broker-api-versions binary found'; exit 1; fi"

docker exec -it $Container bash -lc $cmd

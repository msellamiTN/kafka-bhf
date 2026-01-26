param(
  [string]$Container = "kafka",
  [string]$Bootstrap = "kafka:9093",
  [Parameter(Mandatory=$true)]
  [string]$Args
)

$cmd = "if command -v kafka-topics.sh >/dev/null 2>&1; then kafka-topics.sh --bootstrap-server $Bootstrap $Args; else kafka-topics --bootstrap-server $Bootstrap $Args; fi"

docker exec -it $Container bash -lc $cmd

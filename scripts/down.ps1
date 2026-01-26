param(
  [Parameter(Mandatory=$true)]
  [string]$ComposeFile
)

docker compose -f $ComposeFile down

param(
  [Parameter(Mandatory=$true)]
  [string]$ComposeFile
)

docker compose -f $ComposeFile up -d

param(
  [Parameter(Mandatory=$true)]
  [string]$Container,

  [Parameter(Mandatory=$true)]
  [string]$Cmd
)

docker exec -it $Container bash -lc $Cmd

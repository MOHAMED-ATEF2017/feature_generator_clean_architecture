$env:Path += ";$env:USERPROFILE\.pub-cache\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
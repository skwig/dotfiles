# https://scoop.sh/
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# winget export wingetfile.json --include-versions
winget import ./wingetfile.json

# scoop export > scoopfile.json
scoop import ./scoopfile.json

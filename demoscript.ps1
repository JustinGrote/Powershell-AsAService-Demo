#Powershell As A Service Demo
$lines = [Environment]::NewLine + "===========================================================================================" + [Environment]::NewLine

write-host -fore Green "$lines Step 1: Make sure our environment is good $lines"
Invoke-Build Test




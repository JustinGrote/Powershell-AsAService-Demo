#Powershell As A Service Demo
$lines = [Environment]::NewLine + "===========================================================================================" + [Environment]::NewLine
function startcmd ([scriptblock]$cmd) {
    write-host -fore Cyan "RUNNING COMMAND: $cmd"
    & $cmd
}
function promptstep ($string) {
    write-host -fore Green "$lines $string $lines";read-host "Press enter to continue..."
}

promptstep "Step 1: Make sure our environment is good"
startcmd {Invoke-Build Test}




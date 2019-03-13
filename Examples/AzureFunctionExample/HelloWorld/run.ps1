# AZURE FUNCTIONS CHEAT SHEET
# $req variable has whatever arguments or content were provided in the request
# $res a file handler. Whatever you write here will be returned in the request

#$requestBody = (Get-Content $req -Raw)
#$requestbody > $res

get-variable req* | format-table | out-string

"Hello World" | Out-File $res -Encoding ASCII
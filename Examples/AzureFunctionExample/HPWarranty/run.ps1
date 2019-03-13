#requires -module HPWarranty,PowerHTML

#pn and sn are allowed parameters to specify the product and serial number.

#Dummy Values if parameters not specified
if (-not $REQ_QUERY_pn) { $REQ_QUERY_pn = "459497-B21"}
if (-not $REQ_QUERY_sn) { $REQ_QUERY_sn = "MXQ84504T0"}

$entitlement = Get-HPEntWarrantyEntitlement -ProductNumber $REQ_QUERY_pn -SerialNumber $REQ_QUERY_sn -QueryMethod HPSC -warningaction SilentlyCOntinue | ConvertTo-Json -Depth 5 -Compress:$false
$entitlement > $res
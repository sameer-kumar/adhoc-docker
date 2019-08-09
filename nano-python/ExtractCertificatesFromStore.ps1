$crtDir = "C:\Temp\1\crt"
$pemDir = "C:\Temp\1\pem"
$bundledFile = "C:\Temp\1\ca-bundle.pem"

if(!(Test-Path $crtDir))
{
    New-Item $crtDir -ItemType Directory
}

if(!(Test-Path $pemDir))
{
    New-Item $pemDir -ItemType Directory
}

# Trusted Root CAs
$certs = Get-ChildItem -Path "Cert:\CurrentUser\Root" | Sort-Object 
foreach ($cert in $certs)
{
    if($cert.NotAfter -lt [Datetime]::Today)
    {
        continue;
    }
    
    if($cert.IssuerName.Name.Contains('GlobalSign'))
    {
        "GlobalSign found"
    }


    # Get Issuer
    $issuer = $null
    $arr = $cert.IssuerName.Name.Split(",")
    foreach($item in $arr)
    {
        if($item.IndexOf("CN=") -ge 0)
        {
            $issuer = $item.Trim().Substring(3)
            $issuerFormatter = "="*$issuer.Length
        }
    }

    if($issuer -eq $null)
    {
        foreach($item in $arr)
        {
            if($item.IndexOf("OU=") -ge 0)
            {
                $issuer = $item.Trim().Substring(3)
                $issuerFormatter = "="*$issuer.Length
            }
        }
    }

    if($issuer)
    {
        $crtFilePath = "$crtDir\$issuer"
        $pemFilePath = "$pemDir\$issuer.pem"
        Export-Certificate -FilePath "$crtFilePath" -Cert $cert
        certutil -encode "$crtFilePath" "$pemFilePath"
        

        # Put Issuer as first item in pem file
        "$issuer`r`n$issuerFormatter`r`n" + (Get-Content "$pemFilePath" -Encoding UTF8 -Raw) | Set-Content "$pemFilePath" -Encoding UTF8
    }
    else
    {
        Write-Verbose "Friendly name not found for $cert.IssuerName. Use other name" -Verbose

    }
}

New-Item -ItemType file "$bundledFile" –force
Add-Content -Path "$bundledFile" -Value "##`r`n## Bundle of CA Root Certificates`r`n##`r`n" -Encoding UTF8
Get-ChildItem -Path "$pemDir"  | %{  (Get-Content $_.FullName)+"`r`n" | Add-Content -Path "$bundledFile" -Encoding UTF8}


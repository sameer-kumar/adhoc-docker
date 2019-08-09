param
(
    $ChocolateyPackageFilePath
)

#$localChocolateyPackageFilePath = '.\chocolatey.0.10.15.nupkg'
$localChocolateyPackageFilePath = $ChocolateyPackageFilePath
$ChocoInstallPath = "$($env:SystemDrive)\ProgramData\Chocolatey\bin"
$env:ChocolateyInstall = "$($env:SystemDrive)\ProgramData\Chocolatey"
$env:Path += ";$ChocoInstallPath"
$DebugPreference = "Continue";
$env:ChocolateyEnvironmentDebug = 'true'

function Install-LocalChocolateyPackage 
{
    param 
    (
        [string]$chocolateyPackageFilePath = ''
    )

    if ($chocolateyPackageFilePath -eq $null -or $chocolateyPackageFilePath -eq '') 
    {
        throw "You must specify a local package to run the local install."
    }
    
    if ($env:TEMP -eq $null) 
    {
        $env:TEMP = Join-Path $env:SystemDrive 'temp'
    }

    $chocTempDir = Join-Path $env:TEMP "chocolatey"
    $tempDir = Join-Path $chocTempDir "chocInstall"
    if (![System.IO.Directory]::Exists($tempDir)) 
    {
        [System.IO.Directory]::CreateDirectory($tempDir)
    }

    $file = Join-Path $tempDir "chocolatey.zip"
    Copy-Item $chocolateyPackageFilePath $file -Force
    
    # unzip the package
    Write-Output "Extracting $file to $tempDir..."
    if ($unzipMethod -eq '7zip') 
    {
        $7zaExe = Join-Path $tempDir '7za.exe'
        if (-Not (Test-Path ($7zaExe))) 
        {
            Write-Output "Downloading 7-Zip commandline tool prior to extraction."
            # download 7zip
            Download-File $7zipUrl "$7zaExe"
        }
    
        $params = "x -o`"$tempDir`" -bd -y `"$file`""
        # use more robust Process as compared to Start-Process -Wait (which doesn't
        # wait for the process to finish in PowerShell v3)
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo($7zaExe, $params)
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $process.Start() | Out-Null
        $process.BeginOutputReadLine()
        $process.WaitForExit()
        $exitCode = $process.ExitCode
        $process.Dispose()
    
        $errorMessage = "Unable to unzip package using 7zip. Perhaps try setting `$env:chocolateyUseWindowsCompression = 'true' and call install again. Error:"
        switch ($exitCode) 
        {
            0 { break }
            1 { throw "$errorMessage Some files could not be extracted" }
            2 { throw "$errorMessage 7-Zip encountered a fatal error while extracting the files" }
            7 { throw "$errorMessage 7-Zip command line error" }
            8 { throw "$errorMessage 7-Zip out of memory" }
            255 { throw "$errorMessage Extraction cancelled by the user" }
            default { throw "$errorMessage 7-Zip signalled an unknown error (code $exitCode)" }
        }
    }
    else 
    {
        if ($PSVersionTable.PSVersion.Major -lt 5) 
        {
            try 
            {
                $shellApplication = new-object -com shell.application
                $zipPackage = $shellApplication.NameSpace($file)
                $destinationFolder = $shellApplication.NameSpace($tempDir)
                $destinationFolder.CopyHere($zipPackage.Items(),0x10)
            }
            catch 
            {
                throw "Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = 'false' and call install again to use 7zip to unzip. Error: `n $_"
            }
        }
        else 
        {
            Expand-Archive -Path "$file" -DestinationPath "$tempDir" -Force
        }
    }
    
    # Call chocolatey install
    Write-Output "Installing chocolatey on this machine"
    $toolsFolder = Join-Path $tempDir "tools"
    $chocInstallPS1 = Join-Path $toolsFolder "chocolateyInstall.ps1"
    
    & $chocInstallPS1

    Write-Output 'Ensuring chocolatey commands are on the path'
    $chocInstallVariableName = "ChocolateyInstall"
    $chocoPath = [Environment]::GetEnvironmentVariable($chocInstallVariableName)
    if ($chocoPath -eq $null -or $chocoPath -eq '') 
    {
        $chocoPath = 'C:\ProgramData\Chocolatey'
    }
    
    $chocoExePath = Join-Path $chocoPath 'bin'

    if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) 
    {
        $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
    }
}

Install-LocalChocolateyPackage $localChocolateyPackageFilePath
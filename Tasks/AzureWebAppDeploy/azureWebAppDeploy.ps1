[CmdletBinding()]
param(
    [Parameter(mandatory=$true)][string]$siteName,
    [Parameter()][string]$appName,
    [Parameter(mandatory=$true)][string]$packagePath,
    [Parameter(mandatory=$true)][string]$userName,
    [Parameter(mandatory=$true)][string]$password
)

function Find-Files($searchPattern, $rootFolder) {
    Get-ChildItem -Path $rootFolder $searchPattern -Recurse
}

function Get-SingleFile($files, $pattern) {
    if ($files -is [system.array]) {
        throw "Found more than one file to deploy with search pattern $pattern There can be only one."
    } else {
        if (!$files) {
            throw "No files were found to deploy with search pattern $pattern"
        }
        return $files
    }
}

Write-Host "Site Name: $siteName"
Write-Host "App Name: $appName"
Write-Host "User Name: $userName"

$MSDeployKey = 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3' 
if(!(Test-Path $MSDeployKey)) { 
    throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
} 

$InstallPath = (Get-ItemProperty $MSDeployKey).InstallPath 
if(!$InstallPath -or !(Test-Path $InstallPath)) { 
    throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
} 

$msdeploy = Join-Path $InstallPath "msdeploy.exe" 
if(!(Test-Path $MSDeploy)) { 
    throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command" 
} 

$packageFile = Find-Files -SearchPattern "*.zip" -RootFolder $packagePath
$packageFile = Join-Path $packagePath (Get-SingleFile $packageFile "*.zip")
Write-Host "Package File: $packageFile"

$parametersFile = Find-Files -SearchPattern "*.SetParameters.xml" -RootFolder $packagePath
$parametersFile = Join-Path $packagePath (Get-SingleFile $parametersFile "*.SetParameters.xml")
Write-Host "Parameters File: $parametersFile"

$publishUrl ="https://$siteName.scm.azurewebsites.net:443/msdeploy.axd?site-name=$siteName"
$foo = "$appName"
$webApp = "$siteName"
if ($foo -ne "") {
    $webApp = "$siteName\$foo"
}

Write-Host "Deploying package to $publishUrl for app $($appName)"

$arguments = 
    "-source:package=""$packageFile""",
    "-dest:auto,computerName='$publishUrl',userName='$userName',password='$password',authType='Basic',includeAcls='False'",
    "-setParamFile:""$parametersFile""",
    "-setParam:name='IIS", "Web", "Application", ("Name',value='" + $webApp + "'"),
    "-verb:sync",
    "-allowUntrusted"

Write-Host $arguments

. $msdeploy $arguments
function List-VirtualEnvs-Internal {
    if ($env:VENVROOT -eq $null -or (-not (Test-Path $env:VENVROOT))) { # there is no VENVROOT environment variable
        Throw "Error: VENVROOT environment variable must be defined before List-Venvs cmdlet can be used"
    }

    $venvroot = $env:VENVROOT
    $subfolder = "Scripts" # specify that we're looking in the Scripts folder
    $file = "Activate.ps1" # verify the Scripts folder has the Activate.ps1 file

    # Write-Host "Listing virtualenvs in $venvroot"

    $venvnames = @()

    $venvdirs = Get-ChildItem $venvroot -Directory -Recurse
    foreach ($folder in $venvdirs) {
        if ($folder.Name -eq $subfolder) {
            $filePath = Join-Path $folder.FullName $file
            if (Test-Path $filePath) {
                $venvnames += $folder.Parent.Name
            }
        }
    }

    return $venvnames
}


function List-VirtualEnvs {
    $venvs = List-VirtualEnvs-Internal -Path $Path
    foreach ($venv in $venvs) {
        Write-Host $venv
    }
}

function Activate-VirtualEnv {
    [CmdletBinding()]
    param()
    DynamicParam {
        $ParameterName = 'Name'

        $ParamAttrib = New-Object  System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $true
        $ParamAttrib.Position = 0
        $ParamAttrib.ParameterSetName = '__AllParameterSets'

        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)

        $VenvNames = List-VirtualEnvs-Internal
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($VenvNames)
        $ValidateSetAttribute.ErrorMessage = "The provided venv does not exist in $env:VENVROOT. Valid options are [$VenvNames]"
        $AttribColl.Add($ValidateSetAttribute)

        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string],  $AttribColl)

        $RuntimeParamDic = New-Object  System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add($ParameterName, $RuntimeParam)
        return $RuntimeParamDic
    }

    begin {
        # Bind the parameter to a friendly variable
        $VenvName = $PsBoundParameters[$ParameterName]
    }

    process {
        $VenvPath = Join-Path $env:VENVROOT $VenvName
        if (-not (Test-Path $VenvPath)) {
            Throw "venv $VenvName does not exist in $env:VENVROOT"
        }

        $ScriptPath = Join-Path $VenvPath "Scripts" "Activate.ps1"
        if (-not (Test-Path $ScriptPath)) {
            Throw "Could not find Activate.ps1 script for $VenvName venv"
        }

        Invoke-Expression "& $ScriptPath"
    }
}

Export-ModuleMember -Function List-VirtualEnvs
Export-ModuleMember -Function Activate-VirtualEnv
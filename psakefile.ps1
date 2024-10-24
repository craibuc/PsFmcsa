Properties {
  $ModuleName='PsFmcsa'
}

Task Symlink -description "Create a symlink for '$ModuleName' module" {
  $Here = Get-Location
  # ~/.local/share/powershell/Modules
  $ModulePath = ($ENV:PSModulePath -split ([System.Environment]::OSVersion -eq '' ? ';' : ':'))[0]
  Push-Location $ModulePath 
  ln -s "$Here/$ModuleName" $ModuleName
  Pop-Location
}

Task Publish -description "Publish module '$ModuleName' to repository '$($Env:REPOSITORY_NAME)'" {
  Publish-Module -name $ModuleName -Repository $Env:REPOSITORY_NAME -NuGetApiKey $Env:NUGET_API_KEY
}

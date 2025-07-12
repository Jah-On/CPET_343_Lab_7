powershell -command "Install-Module ps2exe -Scope CurrentUser"

powershell -command "Invoke-ps2exe .\modelsimmer.ps1 .\modelsimmer.exe"
powershell -command "Invoke-ps2exe .\nvcez.ps1 .\nvcez.exe"
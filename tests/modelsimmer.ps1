<#

Author: John Schulz
Created: 29/05/2025

LLM usage notice...
The creation of this script was aided by Google Gemini 3.5 Flash. All code and 
and functionality is verified manually. 

#>

$targetDirectory = "src"

function BlockExit {
    Write-Host ""
    Write-Host "Press Enter to close or close the terminal..." -NoNewline
    Read-Host
}

Clear-Host

# Constants for directory detection.
$currentLocation = Get-Location

# Check if the 'work' directory exists in the current location
if (-not (Test-Path -Path "$currentLocation\$targetDirectory" -PathType Container)) {
    Write-Host "Directory '" -NoNewline -ForegroundColor Yellow
    Write-Host $targetDirectory -NoNewline -ForegroundColor Green
    Write-Host "' not found in the current working directory." -ForegroundColor Yellow

    Write-Host "Assuming GUI script launch..." -ForegroundColor Cyan
    Set-Location ..
    $currentLocation = Get-Location
}

if (-not (Test-Path -Path "$currentLocation\$targetDirectory" -PathType Container)) {
    Write-Host "Directory '" -NoNewline -ForegroundColor Yellow
    Write-Host $targetDirectory -NoNewline -ForegroundColor Green
    Write-Host "' not found in the current working directory." -ForegroundColor Yellow

    Write-Host "You MUST launch this script from the " -NoNewline -ForegroundColor Red
    Write-Host "project root" -NoNewline -ForegroundColor Green
    Write-Host " or from the '" -NoNewline -ForegroundColor Red
    Write-Host "tests" -NoNewline -ForegroundColor Green
    Write-Host "' folder!" -ForegroundColor Red

    BlockExit
    exit -1
}

# Generate "work" library
vlib work

if ($LASTEXITCODE -ne 0){
    Remove-Item -Path .\work
    vlib work
}

# Get all VHDL files and consolidate to relative paths.
$vhdlFiles = (
    Get-ChildItem -Path .\$targetDirectory\*.vhd -Recurse |
    Select-Object -ExpandProperty FullName |
    Sort-Object -Property { 
        $pathParts = $_.Split('\')
        $depth = $pathParts.Count
        # Assign a very high value to testbenches to make it sort last
        if ($pathParts -contains 'testbenches') {
            [int]::MaxValue
        } else {
            $depth
        }
    }, -Descending |
    Resolve-Path -Relative
)

# Get the first matching test bench with the "_tb" pattern.
$testBench = (Get-ChildItem -Path .\$targetDirectory\testbenches\*_tb.vhd | Select-Object -First 1 -ExpandProperty BaseName )

if ($vhdlFiles.Count -eq 0){
    Write-Host "No VHDL files found... exiting." -ForegroundColor Yellow

    BlockExit
    exit -1
}

# Analyze VHDL files
Write-Host ""
Write-Host "Analyzing VHDL files: " -NoNewline -ForegroundColor Cyan
Write-Host $vhdlFiles -NoNewline -ForegroundColor Green
Write-Host "..." -ForegroundColor Cyan

foreach ($file in $vhdlFiles) {
    vcom -2008 -work work $file

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Analysis for '" -NoNewline -ForegroundColor Red
        Write-Host $file -NoNewline -ForegroundColor Green
        Write-Host "' failed!" -ForegroundColor Red

        Write-Host ""
        Write-Host "Press Enter to close or close the terminal..." -NoNewline
        Read-Host
        exit -1
    } else {
        Write-Host "Analysis for '" -NoNewline -ForegroundColor Cyan
        Write-Host $file -NoNewline -ForegroundColor Green
        Write-Host "' successful!" -ForegroundColor Cyan
    }
}

if ([string]::IsNullOrEmpty(($testBench))){
    Write-Host "No testbench found... exiting." -ForegroundColor Yellow

    BlockExit
    exit -1
} else {
    $testBench = $testBench.Replace("_tb", "")
}

Write-Host ""
Write-Host "Elaborating testbench '" -NoNewline -ForegroundColor Cyan
Write-Host $testBench -NoNewline -ForegroundColor Magenta
Write-Host "' and executing .do file..." -ForegroundColor Cyan

# Elaborate the test bench and include do file argument
vsim -voptargs=+acc $testBench -do .\tests\assets\configure_and_run.do 
Start-Sleep -Seconds 5 

if ($LASTEXITCODE -ne 0) {
    Write-Host "Stimulation failed!" -ForegroundColor Red

    BlockExit
    exit -1
} else {
    Write-Host "Stimulated successfully!" -ForegroundColor Cyan
}

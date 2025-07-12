#!/bin/bash

# Author: John Schulz
# Created: 29/05/2025
#
# LLM usage notice...
# The creation of this script was aided by Google Gemini 3.5 Flash. All code and
# and functionality is verified manually.

targetDirectory="src"

# Function to block exit and wait for user input
block_exit() {
    echo ""
    read -p "Press Enter to close or close the terminal..."
}

clear

# Constants for directory detection.
currentLocation=$(pwd)

# Check if the 'work' directory exists in the current location
if [ ! -d "$currentLocation/$targetDirectory" ]; then
    echo -e "\e[33mDirectory '\e[0m\e[32m$targetDirectory\e[0m\e[33m' not found in the current working directory.\e[0m"

    echo -e "\e[36mAssuming GUI script launch...\e[0m"
    cd ..
    currentLocation=$(pwd)
fi

if [ ! -d "$currentLocation/$targetDirectory" ]; then
    echo -e "\e[33mDirectory '\e[0m\e[32m$targetDirectory\e[0m\e[33m' not found in the current working directory.\e[0m"

    echo -e "\e[31mYou MUST launch this script from the \e[0m\e[32mproject root\e[0m\e[31m or from the '\e[0m\e[32mtests\e[0m\e[31m' folder!\e[0m"

    block_exit
    exit -1
fi

# Get all VHDL files and sort them.
# Testbenches are sorted last by assigning a high value to their depth for sorting.
# The `printf '%d\n'` trick is used to simulate a numeric sort key in `sort`.
vhdlFiles=$(find "$currentLocation/$targetDirectory" -name "*.vhd" | sort -r -t '/' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -k 5,5 -k 6,6 -k 7,7 -k 8,8 -k 9,9 -k 10,10 -k 11,11 -k 12,12 -k 13,13 -k 14,14 -k 15,15 -k 16,16 -k 17,17 -k 18,18 -k 19,19 -k 20,20 -k 21,21 -k 22,22 -k 23,23 -k 24,24 -k 25,25 -k 26,26 -k 27,27 -k 28,28 -k 29,29 -k 30,30 -k 31,31 -k 32,32 -k 33,33 -k 34,34 -k 35,35 -k 36,36 -k 37,37 -k 38,38 -k 39,39 -k 40,40 -k 41,41 -k 42,42 -k 43,43 -k 44,44 -k 45,45 -k 46,46 -k 47,47 -k 48,48 -k 49,49 -k 50,50 | while read -r file; do
    relative_path=$(realpath --relative-to="$currentLocation" "$file")
    if [[ "$relative_path" == *"/testbenches/"* ]]; then
        # Assign a very high "depth" for testbenches to sort them last
        printf "99999 %s\n" "$relative_path"
    else
        # Calculate depth for other files
        depth=$(echo "$relative_path" | awk -F'/' '{print NF}')
        printf "%d %s\n" "$depth" "$relative_path"
    fi
done | sort -k1,1nr -k2,2 | awk '{print $2}')

# Get the test bench file name without the .vhd extension
testBench_full_path=$(find "$currentLocation/$targetDirectory/testbenches" -name "*_tb.vhd" -print -quit)
if [ -n "$testBench_full_path" ]; then
    testBench=$(basename "$testBench_full_path" .vhd)
else
    testBench=""
fi

if [ -z "$vhdlFiles" ]; then
    echo -e "\e[33mNo VHDL files found... exiting.\e[0m"

    block_exit
    exit -1
fi

# Analyze VHDL files
echo ""
echo -e "\e[36mAnalyzing VHDL files: \e[0m\e[32m$vhdlFiles\e[0m\e[36m...\e[0m"

# Convert the multiline string into an array for iteration
IFS=$'\n' read -r -d '' -a vhdlFileArray <<< "$vhdlFiles"

for file in "${vhdlFileArray[@]}"; do
    nvc --std=2008 -a "$file"

    if [ $? -ne 0 ]; then
        echo -e "\e[31mAnalysis for '\e[0m\e[32m$file\e[0m\e[31m' failed!\e[0m"

        echo ""
        read -p "Press Enter to close or close the terminal..."
        exit $?
    else
        echo -e "\e[36mAnalysis for '\e[0m\e[32m$file\e[0m\e[36m' successful!\e[0m"
    fi
done

if [ -z "$testBench" ]; then
    echo -e "\e[33mNo testbench found... exiting.\e[0m"

    block_exit
    exit -1
else
    testBench=${testBench/_tb/}
fi

echo ""
echo -e "\e[36mElaborating testbench '\e[0m\e[35m$testBench\e[0m\e[36m'...\e[0m"

# Elaborate the test bench
nvc --std=2008 -e "$testBench"

if [ $? -ne 0 ]; then
    echo -e "\e[31mElaboration failed!\e[0m"

    block_exit
    exit $?
else
    echo -e "\e[36mElaborated successfully!\e[0m"
fi

echo ""
echo -e "\e[36mStimulating testbench '\e[0m\e[35m$testBench\e[0m\e[36m'...\e[0m"

# Run the test bench and generate VCD
nvc --std=2008 -r "$testBench" -w --format=vcd

if [ $? -ne 0 ]; then
    echo -e "\e[31mStimulation failed!\e[0m"

    block_exit
    exit $?
else
    echo -e "\e[36mStimulated successfully!\e[0m"
fi
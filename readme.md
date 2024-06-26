# TriFused - Nacha-Report

## Overview
The `nacha-report.ps1` PowerShell script is designed to read a NACHA `ach` file then produce a more human readable summary report without exposing sensitive account information. This script is useful for auditing and analyzing ACH (Automated Clearing House) transactions while ensuring confidentiality and compliance. 

Nacha File Details from Nacha.org
Ref: https://achdevguide.nacha.org/ach-file-details

## Features
- Reads NACHA formatted ach files and generates a more readable report.
- Omits sensitive account details to maintain privacy.
- Offers options for downloading test data for functionality verification.
- Customizable to show detailed trace information for each transaction.
- Report output can be piped to email and notification tools.

## Version
1.0.10

## Install
Install-Script -Name nacha-report 

## Usage
To use the script, you need to provide the path to the NACHA file you want to analyze. There is also an option to download test data if no file path is provided.

nacha-report.ps1 -testdata -silent -no 67    - simple report without transaction data with information suppressed 

    -nachaFilePath C:\FolderA\FolderB\mynachafile.txt  -- path to nacha file (Any extension will work)
    -testdata       -- Will prompt to download a ACH test file from public google share https://drive.google.com/file/d/1-tEJ6Y_KMvUIuL55DG1oddekG9cD2WMN
    -showTrace6     -- Will show the Trace codes for type 6
    -silent         -- Supress informational messages - Clean report output when piping 
    -no ###         -- remove record types from report


### Basic Command
ps>    

    .\nacha-report.ps1 -nachaFilePath "C:\Path\To\Your\File.txt"

    .\nacha-report.ps1 -testdata

    .\nacha-neport.ps1 -nachaFielPath

    .\nacha-report.ps1 -testdata  -- Use Test data - will prompt to download

    .\nacha-report.ps1 -testdata -no 67     -- Remove type 6 and 7 from report

    .\nacha-report.ps1 -testdata -no 5678   -- Remove type 5, 6, 7 and 8 from report

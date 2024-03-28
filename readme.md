# TriFused - Nacha-Report

## Overview
`nacha-report.ps1` is a PowerShell script designed to read a NACHA ach file and produce a more human readable summary report without exposing sensitive account information. This script is useful for auditing and analyzing ACH (Automated Clearing House) transactions while ensuring confidentiality and compliance.

## Features
- Reads NACHA formatted ach files and generates a concise report.
- Omits sensitive account details to maintain privacy.
- Offers options for downloading test data for functionality verification.
- Customizable to show detailed trace information for each transaction.

## Version
1.0.9

## Install
Install-Script -Name nacha-report 

## Usage
To use the script, you need to provide the path to the NACHA file you want to analyze. There is also an option to download test data if no file path is provided.

### Basic Command
ps>```powershell
.\nacha-report.ps1 -nachaFilePath "C:\Path\To\Your\File.txt"
.\nacha-report.ps1 -testdata
.\nacha-neport.ps1 -nachaFielPath
.\nacha-report.ps1 -testdata  -- Use Test data - will prompt to download
.\nacha-report.ps1 -testdata -no 67     -- Remove type 6 and 7 from report
.\nacha-report.ps1 -testdata -no 5678   -- Remove type 5, 6, 7 and 8 from report

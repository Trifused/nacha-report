# TriFused - Nacha-Report

## Overview
`Nacha-Report.ps1` is a PowerShell script developed by Lawrence Billinghurst at TriFused. It is designed to read a NACHA file and produce a summary report without exposing sensitive account information. This script is useful for auditing and analyzing ACH (Automated Clearing House) transactions while ensuring confidentiality and compliance.

## Features
- Reads NACHA formatted files and generates a concise report.
- Omits sensitive account details to maintain privacy.
- Offers options for downloading test data for functionality verification.
- Customizable to show detailed trace information for each transaction.

## Version
1.0.5

## Usage
To use the script, you need to provide the path to the NACHA file you want to analyze. There is also an option to download test data if no file path is provided.

### Basic Command
```powershell
.\Nacha-Report.ps1 -nachaFilePath "C:\Path\To\Your\File.txt"

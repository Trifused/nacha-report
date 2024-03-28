<#PSScriptInfo

.VERSION 1.0.10

.GUID 2687ebd5-b9f5-403a-bf2b-13fed20fd6cd

.AUTHOR Lawrence Billinghurst larry@trifused.com

.COMPANYNAME TriFused

.COPYRIGHT 2024

.TAGS NACHA ACH BANKING FINTECH PARCE DATA AUTOMATION POWERSHELL

.LICENSEURI https://github.com/Trifused/nacha-report/blob/main/LICENSE

.PROJECTURI https://github.com/Trifused/nacha-report

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
 -added silent switch, updated format, ran Invoke-ScriptAnalyzer, changed write-host to write-output
.PRIVATEDATA

#>

<#

.DESCRIPTION

    NACHA - NACHA (National Automated Clearing House Association) is the organization that
    manages the development, administration, and governance of the ACH Network in the United
    States. The ACH Network is a payment system that allows for the electronic transfer of
    funds between banks and credit unions.

    The NACHA file format adheres to a structure where each line, referred to as a **record**,
    contains exactly 94 characters, making also know as fixed-width ASCII file format.
    These records are organized into various **fields**, each occupying a predetermined position
    within the line.

    A NACHA file contains 6 different types of records:

    Type 1. **File Header**: Starts the file, with details like company name and file creation date.
    Type 5. **Batch Header**: Begins a group of transactions, indicating the payment type and originator.
    Type 6. **Entry Detail**: Represents individual financial transactions, detailing account numbers and amounts.
    Type 7. **Addenda**: Optional, provides extra information for a transaction.
    Type 8. **Batch Control**: Ends a batch, summarizing its transactions and total amount.
    Type 9. **File Control**: Concludes the file, summarizing all batches and entries.

#>


#############################################################################
# TriFused - Nacha-Report
#
# NAME: Nacha-Report.ps1
#
# AUTHOR: Lawrence Billinghurst
# DATE:   3/20/2024
# EMAIL:  larry@trifused.com
#
# VERSION HISTORY
# 1.0 2024-03-20 Initial Version.
# Current: 1.0.10
# > used field mapping from Joshua Nasiatka - Verify-ACH.ps1
# Ref: https://github.com/jossryan/ACH-Verify-Tool
#
# ACH test data generator - https://yawetse.github.io/nachie/
# #############################################################################

<#
.SYNOPSIS
    This script reads a NACH file and outputs a summeary report with out any
    sensitive account informaion

.DESCRIPTION
    NACHA - NACHA (National Automated Clearing House Association) is the organization that
    manages the development, administration, and governance of the ACH Network in the United
    States. The ACH Network is a payment system that allows for the electronic transfer of
    funds between banks and credit unions.

    The NACHA file format adheres to a structure where each line, referred to as a **record**,
    contains exactly 94 characters, making also know as fixed-width ASCII file format.
    These records are organized into various **fields**, each occupying a predetermined position
    within the line.

    A NACHA file contains 6 different types of records:

    Type 1. **File Header**: Starts the file, with details like company name and file creation date.
    Type 5. **Batch Header**: Begins a group of transactions, indicating the payment type and originator.
    Type 6. **Entry Detail**: Represents individual financial transactions, detailing account numbers and amounts.
    Type 7. **Addenda**: Optional, provides extra information for a transaction.
    Type 8. **Batch Control**: Ends a batch, summarizing its transactions and total amount.
    Type 9. **File Control**: Concludes the file, summarizing all batches and entries.



.PARAMETER ParameterName
    -nachaFilePath C:\FolderA\FolderB\mynachafile.txt  -- path to nacha file (Any extension will work)
    -testdata       -- Will auto download some test data
    -showTrace6     -- Will show the Trace codes for type 6
    -silent         -- Clean report output when piping 
    -no ###         -- remove record types from report

.EXAMPLE
    .\nacha-neport.ps1 -nachaFielPath
    .\nacha-report.ps1 -testdata  -- Use Test data - will prompt to download
    .\nacha-report.ps1 -testdata -no 67     -- Remove type 6 and 7 from report
    .\nacha-report.ps1 -testdata -no 5678   -- Remove type 5, 6, 7 and 8 from report


.NOTES
    Additional information about the script, like its version, author, or history.

    # #############################################################################
    # VERSION HISTORY
    # 1.0 2024-03-20 Initial Version.
    # > used ACH field mapping from Joshua Nasiatka - Verify-ACH.ps1 // Thanks!!
    # Ref: https://github.com/jossryan/ACH-Verify-Tool
    #
    # NACH test data generator - https://yawetse.github.io/nachie/
    # #############################################################################

    Report Format
        --------->>> NACHA File Report <<<---------
        NACHA File Name: ach-test-file.txt
        NACHA File Date: January 06, 2015
        NACHA File Time: 12:13 PM

        1, [File Date-YYMMDD], [File Time-HHmm], [Destination Name], [Org Name]
        5, Batch Start: [Batch Number], Info: [Transaction Description], [Effective Date]
            6, [Trans Code], {[Trace Number]}, [Reciver Name], [Amount]
            6, [Trans Code], {[Trace Number]}, [Reciver Name], [(Amount) <--debit]
                7, [Addenda Type Code], [Payment Related Information], [Addenda Sequence Number], [Entry Detail Sequence Number]
        8, Batch End: [Batch Number], Entry Cound: [ in Batch], [(Debit Total)],[Credit Total]
        9, [Batch Count],[Block Count], [Entry Count], [(Debit Total)],[Credit Total]
        --------->>> NACHA File Report End <<<---------


.LINK
    A link to more information or documentation related to the script.

#>

# Script logic starts here

param (
    [string]$nachaFilePath=""
    ,[switch]$showTrace6
    ,[string]$no
    ,[switch]$silent
    ,[switch]$testdata
)

# Get the directory where the script is located
$scriptDirectory = $PSScriptRoot

# Output the directory path
if (-not $silent) {
    Write-Output "`This Script is running from: $scriptDirectory"
    }
$defultTestDataFileName = $scriptDirectory + "\test-nacha-file.txt"


# Test data and file processing
if (-not ($testdata) ){

    if (-not $nachaFilePath)  {
        if (-not $silent){
            Write-Output "Usage: ./nacha-report.ps1 -nachaFilePath <Path to NACHA file>"
            Write-Output  "Usage: ./nacha-report.ps1 -testdata"
        }
        exit 1
    }

    } else{
    if ($testdata) {
        if (-not (Test-Path $defultTestDataFileName )) {
            #Write-Host "Test data file not found downloading."
            Write-Output "Test data file not found."

            # Ask the user if they want to download the test nacha file
            $testfileuri = "https://drive.google.com/file/d/1-tEJ6Y_KMvUIuL55DG1oddekG9cD2WMN"
            Write-Output "View the test nacha data file at: $($testfileuri)/view"
            $userInput = Read-Host "Do you want to download the test nacha data file? (Y/N)"

            if ($userInput -eq 'Y' -or $userInput -eq 'y') {
                        # Assuming $defultTestDataFileName is defined earlier in the script
                        $outputPath = $defultTestDataFileName
                        # The direct download URL should be different from the view URL
                        # Convert Google Drive view link to download link (this may require a different approach for actual downloading)
                        $url = $testfileuri.Replace("/file/d/", "/uc?export=download&id=").Replace("/view", "")
                        # Create a web client object
                        $client = New-Object System.Net.WebClient

                        try {
                            $client.DownloadFile($url, $outputPath)
                            Write-Output "File downloaded successfully to: $outputPath"
                        }
                        catch {
                            Write-Output "An error occurred during file download: $_"
                        }
            } else {
                Write-Output "Download canceled by the user."
                exit 1
                }
        }
        #$nachaFilePath
        $nachaFilePath = $defultTestDataFileName
        #$nachaFilePath
        }

    #$nachaFilePath = $defultTestDataFileName

        if (-not (Test-Path $nachaFilePath) ) {
            Write-Output "Error: File not found."
            exit 1
        }
}

Function ReadACHLine ($line) {

    # Get record type
    # 1 File Header Record
    # 5 Company/Batch Header Record
    # 6 Entry Detail Record (CCD/PPD Entries)
    # 7 Addenda Record
    # 8 Batch Control Record
    # 9 File Control Record
    # used field mapping from Joshua Nasiatka - Verify-ACH.ps1 script

    $record_type = $line.substring(0,1).trim()
    if ($line -ne '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999') {
     }

    # 1 - FILE HEADER RECORD
    if ($record_type -eq '1') {

        $record_details = [PSCustomObject]@{
            'record_type'                      = $line.substring(0,1).trim()
            'priority_code'                    = $line.substring(1,2).trim()
            'immediate_destination'            = $line.substring(3,10).trim()
            'immediate_origin'                 = $line.substring(13,10).trim()
            'file_creation_date'               = $line.substring(23,6).trim()
            'file_creation_time'               = $line.substring(29,4).trim()
            'file_id_modifier'                 = $line.substring(33,1).trim()
            'record_size'                      = $line.substring(34,3).trim()
            'blocking_factor'                  = $line.substring(37,2).trim()
            'format_code'                      = $line.substring(39,1).trim()
            'immediate_destination_name'       = $line.substring(40,23).trim()
            'immediate_origin_name'            = $line.substring(63,23).trim()
            'reference_code'                   = $line.substring(86,8).trim()
        }

        # ##### Add Line to Output Record
        $ACHContents.Add($record_details) |Out-Null
        # #####

    # 5 - COMPANY/BATCH HEADER RECORD
    } elseif ($record_type -eq '5') {

        $record_details = [PSCustomObject]@{
            'record_type'                      = $line.substring(0,1).trim()
            'service_class_code'               = $line.substring(1,3).trim()
            'company_name'                     = $line.substring(4,16).trim()
            'company_discretionary_data_5'       = $line.substring(20,20).trim()
            'company_identification'           = $line.substring(40,10).trim()
            'standard_entry_class_code'        = $line.substring(50,3).trim()
            'company_entry_description'        = $line.substring(53,10).trim()
            'company_descriptive_date'         = $line.substring(63,6).trim()
            'effective_entry_date'             = $line.substring(69,6).trim()
            'settlement_date'                  = $line.substring(75,3).trim()
            'originator_status_code'           = $line.substring(78,1).trim()
            'originating_dfi_identification'   = $line.substring(79,8).trim()
            'batch_number'                     = $line.substring(87,7).trim()
        }
        # ##### Add Line to Output Record
        $ACHContents.Add($record_details) |Out-Null
        # #####

    # 6 - ENTRY DETAIL RECORD (CCD/PPD ENTRIES)
    } elseif ($record_type -eq '6') {

        $record_details  = [PSCustomObject]@{
            'record_type'                      = $line.substring(0,1).trim()
            'transaction_code'                 = $line.substring(1,2).trim()
            'receiving_dfi_identification'     = $line.substring(3,8).trim()
            'check_digit'                      = $line.substring(11,1).trim()
            'dfi_account_number'               = $line.substring(12,17).trim()
            'amount'                           = $(try{($line.substring(29,10).trim())/100}catch{$line.substring(29,10).trim()})
            'individual_identification_number' = $line.substring(39,15).trim()
            'individual_name'                  = $line.substring(54,22).trim()
            'company_discretionary_data_6'     = $line.substring(76,2).trim()
            'addenda_record_indicator'         = $line.substring(78,1).trim()
            'trace_number'                     = $line.substring(79,15).trim()
        }

        # ##### Add Line to Output Record
        $ACHContents.Add($record_details) |Out-Null
        # #####

    # 7 - ADDENDA RECORD
    } elseif ($record_type -eq '7') {

        $record_details = [PSCustomObject]@{
            'record_type'                      = $line.substring(0,1).trim()
            'addenda_type_code'                = $line.substring(1,2).trim()
            'addenda_related'                  = $line.substring(3,80).trim()
            'addenda_sequence_number'          = $line.substring(83,4).trim()
            'entry_detail_sequence_number'     = $line.substring(87,7).trim()
        }

        # ##### Add Line to Output Record
        $ACHContents.Add($record_details) |Out-Null
        # #####

    # 8 - BATCH CONTROL RECORD
    } elseif ($record_type -eq '8') {

        $record_details = [PSCustomObject]@{
            'record_type'                      = $line.substring(0,1).trim()
            'service_class_code'               = $line.substring(1,3).trim()
            'entry_addenda_count_8'              = $line.substring(4,6).trim()
            'entry_hash'                       = $line.substring(10,10).trim()
            'total_debit_entry'                = $(try{($line.substring(20,12).trim())/100}catch{$line.substring(20,12).trim()})
            'total_credit_entry'               = $(try{($line.substring(32,12).trim())/100}catch{$line.substring(32,12).trim()})
            'company_identification'           = $line.substring(44,10).trim()
            'message_authorization_code'       = $line.substring(54,19).trim()
            'reserved_8'                         = $line.substring(73,6).trim()
            'originating_dfi_identification'   = $line.substring(79,8).trim()
            'batch_number'                     = $line.substring(87,7).trim()
        }

        # ##### Add Line to Output Record
        $ACHContents.Add($record_details) |Out-Null
        # #####
    # 9 - FILE CONTROL RECORD
    } elseif ($record_type -eq '9') {
        if ($line -ne '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999') {

            $record_details = [PSCustomObject]@{
                'record_type'                      = $line.substring(0,1).trim()
                'batch_count'                      = $line.substring(1,6).trim()
                'block_count'                      = $line.substring(7,6).trim()
                'entry_addenda_count_9'              = $line.substring(13,8).trim()
                'entry_hash'                       = $line.substring(21,10).trim()
                'total_debit_entry_in_file'        = $(try{($line.substring(31,12).trim())/100}catch{$line.substring(31,12).trim()})
                'total_credit_entry_in_file'       = $(try{($line.substring(43,12).trim())/100}catch{$line.substring(43,12).trim()})
                'reserved_9'                         = $line.substring(55,39).trim()
            }

            # ##### Add Line to Output Record
            $ACHContents.Add($record_details) |Out-Null
            # #####
        } else {
            #Write-Output ">>>End of File"
        }

    # NO OTHER RECORD TYPES
    } else {
        Write-Warning "Invalid record, skipping..."
        return
    }
}



############################################################################################################################################

# Load the nacha file in memory

if (-not $silent) {Write-Output "Reading File:  $nachaFilePath"}
$nachaFileContent = Get-Content $nachaFilePath


#clear Output varable
[System.Collections.ArrayList]$ACHContents = @()

# Loop through each line and parse the contents
foreach ($line in $nachaFileContent) {
       ReadACHLine($line)
       }

if (-not $silent) {Write-Output "NACHA File Parsing completed.`r`n"}

# Build the Report
$NachaFileTime =""
$FinalReport =  "`r`n--------->>> NACHA File Report <<<---------`r`n`n" # Clear and Start building report
$NachafileName = Split-Path -Path $nachaFilePath -Leaf
$FinalReport = $FinalReport + "NACHA File Name: " + $NachafileName + "`r`n"

$ACHContents | ForEach-Object {
    $currentObject = $_
    switch ($currentObject.record_type) {
        "1" {
                 $NachaFileDate=$($currentObject.file_creation_date)
                 $NachaFileTime=$($currentObject.file_creation_time)
                 # Parse the date string into a DateTime object
                 $parsedDate = [DateTime]::ParseExact($NachaFileDate, "yyMMdd", $null)
                 $parsedTime = [DateTime]::ParseExact($NachaFileTime, "HHmm", $null)
                 # Convert the DateTime object into a long date format string and add to report
                 $FinalReport += "NACHA File Date: " + $parsedDate.ToString("MMMM dd, yyyy") +  "`r`n" # Add Date to Report
                 $FinalReport += "NACHA File Time: " + $parsedTime.ToString("hh:mm tt") + "`r`n" # Add Time to Report
                if (-not($no.Contains($currentObject.record_type))) {
                   $ReportOut = "$($currentObject.record_type), $($currentObject.file_creation_date), $($currentObject.file_creation_time), $($currentObject.immediate_destination_name), $($currentObject.immediate_origin_name)"
                    $FinalReport += "`n"+$ReportOut # Add data to report
                    break
                }

            }
         "5" {
                if (-not($no.Contains($currentObject.record_type))) {
                    $parsedDate = [DateTime]::ParseExact($currentObject.effective_entry_date, "yyMMdd", $null)
                    $EffFormatedDate = " Effective Date: [" + $parsedDate.ToString("MMM/dd/yyyy")  # Add Effective Entry Date to Report
                    $ReportOut = "  $($currentObject.record_type), Start Batch: $($currentObject.batch_number), Info: $($currentObject.company_entry_description),$EffFormatedDate] "
                    $FinalReport += "`n"+$ReportOut # Add data to report
                    break
                }

             }
         "6" {
            if (-not($no.Contains($currentObject.record_type))) {
                    $TransactionCode = $($currentObject.transaction_code)
                    switch ($TransactionCode){
                        { $_ -in "22", "32" } {$formattedamount =  "{0:N2}" -f $($currentObject.amount)}
                        { $_ -in "27", "37" } {$formattedamount =  "({0:N2})" -f $($currentObject.amount)}
                    }

                    #ShowTrace6 Switch Logic

                    $ReportOut = "     $($currentObject.record_type), $TransactionCode"
                    if ($ShowTrace6) {
                        $ReportOut += ", $($currentObject.trace_number)"
                    }
                    $ReportOut += ", $($currentObject.individual_name), $formattedamount"
                    $FinalReport += "`n"+$ReportOut # Add data to report
                    break
                }

        }
         "7" {

            if ((-not($no.Contains($currentObject.record_type)))) {
                $ReportOut =  "         $($currentObject.record_type), $($currentObject.addenda_type_code),  $($currentObject.entry_detail_sequence_number),  $($currentObject.addenda_related)"
                $FinalReport += "`n"+$ReportOut # Add data to report
                $FinalReport += "`n"+$ReportOut # Add data to report
                break
            }

        }
        "8" {
            if (-not($no.Contains($currentObject.record_type))) {
                $formattedDebitTotal =  "({0:N2})" -f $($currentObject.total_debit_entry)
                $formattedCreditTotal =  "{0:N2}" -f $($currentObject.total_credit_entry)
                $ReportOut =  "  $($currentObject.record_type),   End Batch: $($currentObject.batch_number), Entry Count: $($currentObject.entry_addenda_count_8), $formattedDebitTotal,$formattedCreditTotal"
                $FinalReport += "`n"+$ReportOut # Add data to report
                break
             }

        }
        "9" {
            if (-not($no.Contains($currentObject.record_type))) {
                $formattedDebitTotal =  "({0:N2})" -f $($currentObject.total_debit_entry_in_file)
                $formattedCreditTotal =  "{0:N2}" -f $($currentObject.total_credit_entry_in_file)
                $ReportOut = "$($currentObject.record_type), $($currentObject.batch_count),$($currentObject.block_count), $($currentObject.entry_addenda_count_9), $formattedDebitTotal,$formattedCreditTotal"+"`n"
                $FinalReport += "`r`n`n"+$ReportOut # Add data to report - pushed 9 down 1 line
                break
            }

        }
    }

}

$FinalReport += "`n--------->>> NACHA File Report End <<<---------`n" # Add end to report

return $FinalReport

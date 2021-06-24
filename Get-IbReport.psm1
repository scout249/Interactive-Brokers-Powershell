<#
.Synopsis
Importing transaction history from Interactive Brokers.

.Description
The `Get-IbReport` cmdlet import transaction history from Interactive Brokers using flex query version 3 API.
Interactive Brokers provides two types of statements. The Activity Flex and Trade Confirms Flex.
Activity Flex statement provides daily data with all information at the end of the day (Total equity, open positions, trades, cash transactions etc.)
Trade Confirms Flex provides the trades only but it is refreshed immediately after the trade is confirmed.

.Parameter Query
Flex query ID of Interactive Brokers.

.Parameter Token
Your flex web service token in Interactive Brokers.

.Example
Get-IbReport -Query 123456

.Example
Get-IbReport 123456

.Example
Get-IbReport 123456 | Sort-Object settledate | Select-Object -Last 15 | Format-Table

.LINK
Online version: https://www.interactivebrokers.com/en/software/am/am/reports/flex_web_service_version_3.htm
Project homepage: https://github.com/scout249/Interactive-Brokers-Powershell
#>

function Get-IbReport {
  [CmdletBinding()]
  param(
    [string]$Query,
    [switch]$Token
  )
  $path = [Environment]::GetFolderPath('ApplicationData')
  $Colors = @{
    ForegroundColor = "White"
    BackgroundColor = "Red"
  }
  if ($token -ne $true) {
    if ((Test-Path "$path\IbToken.txt") -ne $true) {
      Write-Host "Please run 'Get-IbReport -Token' to provide Interactive Brokers token (Missing)" @colors
    }
    elseif ($query -eq '') {
      Write-Host "Please run 'Get-IbReport -Query <<YOUR QUERY ID>>' to provide Interactive Brokers query ID (Missing)" @colors
    }
    else {
      ## Define variables
      $ib_token = Get-Content "$path\IbToken.txt"
      $ib_version = 3
      $init_url = "https://gdcdyn.interactivebrokers.com/Universal/servlet/FlexStatementService.SendRequest"
      $getdata_url = "https://gdcdyn.interactivebrokers.com/Universal/servlet/FlexStatementService.GetStatement"

      #Authenticate to server
      $Body = @{
        t = $ib_token
        q = $query
        v = $ib_version
      }


      try { $response = Invoke-WebRequest $init_url -Body $Body -Method 'POST' } catch { Write-Host @colors $_.Exception.Response.StatusCode.Value__ $_.Exception.Response.StatusCode }


      [xml]$ib_ref = $response.Content

      $status = $ib_ref.FlexStatementResponse.status
      $errorCode = $ib_ref.FlexStatementResponse.ErrorCode
      $errorMessage = $ib_ref.FlexStatementResponse.ErrorMessage

      if ($status -eq "Fail") {
        Write-Host "$errorCode $status $errorMessage" @colors
      }

      else {

        # Display IB Response Code
        # $ib_ref.FlexStatementResponse.ReferenceCode

        #Retrieve statement data
        $Body = @{
          q = $ib_ref.FlexStatementResponse.ReferenceCode
          t = $ib_token
          v = $ib_version
        }
        $response = Invoke-WebRequest $getdata_url -Body $Body -Method 'POST'
        [xml]$xml = $response.Content

        #TCF
        if ($xml.FlexQueryResponse.type -eq "TCF") {
          $result = $xml.FlexQueryResponse.FlexStatements.FlexStatement.TradeConfirms.TradeConfirm
        }

        #AF
        if ($xml.FlexQueryResponse.type -eq "AF") {
          $result = $xml.FlexQueryResponse.FlexStatements.FlexStatement.ChangeInDividendAccruals.ChangeInDividendAccrual
        }

        #Print result
        return $result
      }
    }
  }
  else {
    Read-Host -Prompt "`nPlease provide token" | Out-File $path\IbToken.txt -Force
    Write-Host "`nYou can now run this with -Query to get report information" -ForegroundColor Green
    Write-Host "If you need to change the token, please run 'Get-IbReport -token' again`n" -ForegroundColor Green
  }
}
Export-ModuleMember -Function Get-IbReport

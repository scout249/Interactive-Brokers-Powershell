# Interactive-Brokers-Powershell

A module for checking report via the Interactive Brokers API

## Setup
1. Download the Interactive Report module. Clone it, zip it or get it from the PowerShell Gallery:
```
Install-Module -Name Get-IbReport -Scope CurrentUser
```
2. Import the module.  This takes a few seconds the first time but is fast thereafter.
```
Import-Module Get-IbReport
```
3. Confirm it is loaded correctly:
```
Get-Help Get-IbReport

NAME
    Get-IbReport

SYNOPSIS
    Displays flex query results from Interactive Brokers.


SYNTAX
    Get-IbReport [-Token] <String> [-Query] <String>

...more text...

```



https://www.interactivebrokers.com/en/software/am/am/reports/flex_web_service_version_3.htm

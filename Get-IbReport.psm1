		  $ib_token = Get-Content "$env:appdata\Microsoft\Windows\PowerShell\IbToken.txt"
		  $ib_version = 3
		  $init_url = "https://gdcdyn.interactivebrokers.com/Universal/servlet/FlexStatementService.SendRequest"
		  $getdata_url = "https://gdcdyn.interactivebrokers.com/Universal/servlet/FlexStatementService.GetStatement"
		  $query = "562838"
		  #$query = 0
		  #Authenticate to server
		  $Body = @{
			t = $ib_token
			q = $query
			v = $ib_version
		  }
		  
		  try { $response = Invoke-WebRequest $init_url -Body $Body -Method 'POST' } catch { Write-host -ForegroundColor White -BackgroundColor Red $_.Exception.Response.StatusCode.Value__ $_.Exception.Response.StatusCode }	
			
			
			[xml]$xml = $response.Content
			
			$status = $xml.FlexStatementResponse.status
			$errorCode = $xml.FlexStatementResponse.ErrorCode
			$errorMessage = $xml.FlexStatementResponse.ErrorMessage
			
			if ($status -eq "Fail") {
				Write-host "$errorCode $status $errorMessage" -ForegroundColor White -BackgroundColor Red
			}
			else {
			# Run Query Here
			Write-host "Run Query"
			}

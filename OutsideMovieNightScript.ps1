$MovieName1 = 'ERNEST SCARED STUPID.mp4'
$MovieName2 = 'FREE GUY.mp4'
$MovieTimeOffSet = 150
$DoubleFeatureIntermission = 600





curl.exe -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightStart
$filePath = Join-Path (Get-Location).Path 'Movies'
$shell = New-Object -COMObject shell.Application
$shellfolder = $shell.Namespace($filePath)
$fullPath1 = Join-Path $filePath $MovieName1
$MovieTime1 = $shellfolder.GetDetailsOf($shellfolder.ParseName($MovieName1), 27)
$MovieTimeOffSet1 = $MovieTimeOffSet
$MovieTimeDelay1 = [TimeSpan]::Parse($MovieTime1).TotalSeconds - $MovieTimeOffSet1
if ( $MovieTimeDelay1 -lt $MovieTimeOffSet1 ) {
	$MovieTimeOffSet1 = [TimeSpan]::Parse($MovieTime1).TotalSeconds
}
Start-Process $fullPath1 -WindowStyle maximized ; Start-Sleep -seconds 3 ; [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') ; [System.Windows.Forms.SendKeys]::SendWait("{F11}")
clear
Start-Sleep -Seconds $MovieTimeDelay1
curl.exe -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOn
Start-Sleep -Seconds $MovieTimeOffSet1
if ( $MovieName2 -ne '' ) {
	Stop-Process -Name "mpc-hc64"
	Start-Sleep -Seconds 1
	$AfterParty = Join-Path (Get-Location).Path 'AfterParty.mp4'
	Start-Process $AfterParty -WindowStyle maximized ; Start-Sleep -seconds 3 ; [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') ; [System.Windows.Forms.SendKeys]::SendWait("{F11}")
	Start-Sleep -Seconds 15
	Stop-Process -Name "mpc-hc64"
	Start-Process C:\Windows\System32\MarineAquarium3.scr
	$fullPath2 = Join-Path $filePath $MovieName2
	$MovieTime2 = $shellfolder.GetDetailsOf($shellfolder.ParseName($MovieName2), 27)
	$MovieTimeOffSet2 = $MovieTimeOffSet
	$MovieTimeDelay2 = [TimeSpan]::Parse($MovieTime2).TotalSeconds - $MovieTimeOffSet2
	if ( $MovieTimeDelay2 -lt $MovieTimeOffSet2 ) {
		$MovieTimeOffSet2 = [TimeSpan]::Parse($MovieTime2).TotalSeconds
	}
	Start-Sleep -Seconds $DoubleFeatureIntermission
	curl.exe -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightDoubleFeatureStart
	Stop-Process -Name "MarineAquarium3.scr"
	Start-Process $fullPath2 -WindowStyle maximized ; Start-Sleep -seconds 3 ; [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') ; [System.Windows.Forms.SendKeys]::SendWait("{F11}")
	Start-Sleep -Seconds $MovieTimeDelay2
	curl.exe -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOn
	Start-Sleep -Seconds $MovieTimeOffSet2
}
Stop-Process -Name "mpc-hc64"
Start-Process C:\Windows\System32\MarineAquarium3.scr
Echo "Trun Off Outside Lights"
Pause
curl.exe -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOff
shutdown -s -f -y -t 30
#shutdown -a

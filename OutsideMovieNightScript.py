$MovieName1 = 'ERNEST SCARED STUPID.mp4'
$MovieName2 = 'FREE GUY.mp4'
$MovieTimeOffSet = 150
$DoubleFeatureIntermission = 600
$filePath = 'C:\Users\Kurt Schwob\Videos\Movies\'





#Get-NetAdapter
#Enable-NetAdapter -Name 'Wi-Fi' -Confirm:$false -AsJob | Wait-Job
#Echo ""
#Echo "Turning Wi-Fi on"
#while ((Get-NetAdapter -Name 'Wi-Fi' | where MediaConnectionState -eq 'Connected') -eq $null) {
#	Start-Sleep -Seconds 1
#	Echo "Connecting..."
#}
#Echo "Wi-Fi turned on"
#Start-Sleep -Seconds 5
curl.exe -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightStart
$fullPath1 = $filePath + $MovieName1
$shell1 = New-Object -COMObject shell.Application
$folder1 = Split-Path $fullPath1
$file1 = Split-Path $fullPath1 -Leaf
$shellfolder1 = $shell1.Namespace($folder1)
$shellfile1 = $shellfolder1.ParseName($file1)
$MovieTime1 = $shellfolder1.GetDetailsOf($shellfile1, 27);
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
	Start-Process 'C:\Users\Kurt Schwob\Videos\AfterParty.mp4' -WindowStyle maximized ; Start-Sleep -seconds 3 ; [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') ; [System.Windows.Forms.SendKeys]::SendWait("{F11}")
	Start-Sleep -Seconds 15
	Stop-Process -Name "mpc-hc64"
	Start-Process C:\Windows\System32\MarineAquarium3.scr
	$fullPath2 = $filePath + $MovieName2
	$shell2 = New-Object -COMObject shell.Application
	$folder2 = Split-Path $fullPath2
	$file2 = Split-Path $fullPath2 -Leaf
	$shellfolder2 = $shell2.Namespace($folder2)
	$shellfile2 = $shellfolder2.ParseName($file2)
	$MovieTime2 = $shellfolder2.GetDetailsOf($shellfile2, 27); 
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

# Variables
$videoFolder = "C:\Users\Schwoby\Videos"
$movieFolder = Join-Path $videoFolder "Movies"
$movieVideoFolder = Join-Path $videoFolder "Videos"
$movieListPath = Join-Path $videoFolder "MovieList.txt"
$MovieTimeOffSet = 300
$Intermission = 600
$IntroClip = "MovieNight.mp4"
$EndClip1 = "AfterParty.mp4"
$EndClip2 = "FerrisBueller.mp4"
$CurlOption1 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightStart }
$CurlOption2 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOn }
$CurlOption3 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOff }
$CurlOption4 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightDoubleFeatureStart }





# Webhook call for start notification
$CurlRun1 = $CurlOption1
$CurlRun2 = $CurlOption2

# Minimize All Windows
$Shell = New-Object -ComObject "Shell.Application"
$Shell.MinimizeAll()

try {
    $movies = @(Get-Content -Path $movieListPath)
    $lastIndex = $movies.Count - 1

	&$CurlRun1
    foreach ($i in 0..$lastIndex) {
        $mainMovie = $movies[$i]
        $isLast = ($i -eq $lastIndex)

        try {
            $file1 = Join-Path $movieVideoFolder $IntroClip
            $file2 = Join-Path $movieFolder $mainMovie
            $file3 = if ($isLast) {
                Join-Path $movieVideoFolder $EndClip1
				$CurlRun3 = $CurlOption3
            } else {
                Join-Path $movieVideoFolder $EndClip1
				$CurlRun3 = $CurlOption4
            }

            # Launch MPC-HC once with all three files in one call and capture the process
            $mpcProcess = Start-Process "mpc-hc64" -ArgumentList "`"$file1`"", "`"$file2`"", "`"$file3`"", "/play" -PassThru

            # Calculate and display total playlist duration
            $shell = New-Object -ComObject Shell.Application
            $items = @($file1, $file2, $file3)
            $totalSeconds = 0
            foreach ($file in $items) {
                $folder = $shell.Namespace((Split-Path $file))
                $item = $folder.ParseName((Split-Path $file -Leaf))
                $duration = $folder.GetDetailsOf($item, 27)  # 27 = Length
                if ($duration -and $duration -match "(\d+):(\d+):(\d+)") {
                    $h = [int]$matches[1]
                    $m = [int]$matches[2]
                    $s = [int]$matches[3]
                } elseif ($duration -and $duration -match "(\d+):(\d+)") {
                    $h = 0
                    $m = [int]$matches[1]
                    $s = [int]$matches[2]
                } else {
                    $h = $m = $s = 0
                }
                $totalSeconds += ($h * 3600 + $m * 60 + $s)
            }
            Write-Host "Playlist duration: $totalSeconds seconds"

            # Optional fullscreen
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
            Start-Sleep -Seconds 3  # Give player time to start before sending keys
            [System.Windows.Forms.SendKeys]::SendWait("{F11}")

            # Sleep for duration of Videos
            if ($totalSeconds -lt $MovieTimeOffSet) {
                $MovieOffSet = $totalSeconds
                $totalSeconds = 0
            } else {
                $totalSeconds = $totalSeconds - $MovieTimeOffSet
                $MovieOffSet = $MovieTimeOffSet
			}
			Start-Sleep -Seconds 1
            Write-Host "Main Play duration: $totalSeconds"
            Start-Sleep -Seconds $totalSeconds
			&$CurlRun2
            Write-Host "Offset duration: $MovieOffSet"
            Start-Sleep -Seconds $MovieOffSet
            Stop-Process -Name "mpc-hc64" -ErrorAction SilentlyContinue

            # Wait for MPC-HC to exit naturally (end of playlist)
            do {
                Start-Sleep -Seconds 1
            } while (-not $mpcProcess.HasExited)

			# Intermission
			Start-Process C:\Windows\System32\MarineAquarium3.scr
            Start-Sleep -Seconds $Intermission
			&$CurlRun3
			Stop-Process -Name "MarineAquarium3.scr" -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host ("Error processing movie '{0}' at index {1}:" -f $mainMovie, $i)
            Write-Host $_
        }
    }
}
catch {
    Write-Host "Fatal error:"
    Write-Host $_
}
finally {
	shutdown -s -f -y -t 1	# start shutdown
	# shutdown -a	# cancel shutdown
}

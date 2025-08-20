# Lighting Controls null seed
$CurlRun1 = { }
$CurlRun2 = { }
$CurlRun3Option1 = { }
$CurlRun3Option2 = { }

# Load variables (assumes Variables.ps1 is in the same folder as this script)
. "$PSScriptRoot\Variables.ps1"

# Minimize All Windows
$Shell = New-Object -ComObject "Shell.Application"
$Shell.MinimizeAll()
$IntroClips = Get-Content -Path $introClipListPath
$IntermissionClips = Get-Content -Path $intermissionClipListPath
$EndClips = Get-Content -Path $endClipListPath

try {
    $movies = @(Get-Content -Path $movieListPath)
    $lastIndex = $movies.Count - 1

	&$CurlRun1
    foreach ($i in 0..$lastIndex) {
        $mainMovie = $movies[$i]
        $isLast = ($i -eq $lastIndex)

        try {
            $file1 = if ($IntroClips) { Join-Path $clipsFolder (Get-Random -InputObject $IntroClips) } else { $null }
            $file2 = Join-Path $movieFolder $mainMovie
			if ($isLast) {
				$CurlRun3 = $CurlRun3Option1
				$file3 = if ($EndClips) { Join-Path $clipsFolder (Get-Random -InputObject $EndClips) } else { $null }
			} else {
				$CurlRun3 = $CurlRun3Option2
				$file3 = if ($IntermissionClips) { Join-Path $clipsFolder (Get-Random -InputObject $IntermissionClips) } else { $null }
			}

            # Launch MPC-HC once with all three files in one call and capture the process
			$arguments = @(
				@($file1, $file2, $file3) | Where-Object { $_ } | ForEach-Object { "`"$($_)`"" }
			)
			$arguments += "/play /fullscreen /close"
			$mpcProcess = Start-Process "mpc-hc64" -ArgumentList $arguments -PassThru

            # Calculate and display total playlist duration
			$shell = New-Object -ComObject Shell.Application
			$items = @($file1, $file2, $file3) | Where-Object { $_ -and (Test-Path $_) }
			$totalSeconds = 0
			foreach ($file in $items) {
				$folder = $shell.Namespace((Split-Path $file))
				$item = $folder.ParseName((Split-Path $file -Leaf))
				$duration = $folder.GetDetailsOf($item, 27)  # 27 = Video Time Length
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
            Write-Host ""
            Start-Sleep -Seconds $MovieOffSet

            # Wait for MPC-HC to exit naturally (end of playlist)
			while (-not $mpcProcess.HasExited) {
				Start-Sleep -Seconds 1
			}

			# Intermission
			if (Test-Path "C:\Windows\System32\MarineAquarium3.scr") {
				Start-Process "C:\Windows\System32\MarineAquarium3.scr"
				Start-Sleep -Seconds $Intermission
				&$CurlRun3
				Stop-Process -Name "MarineAquarium3.scr" -ErrorAction SilentlyContinue
			} else {
				Start-Sleep -Seconds $Intermission
				&$CurlRun3
			}
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
	Read-Host # Pauses until Enter is pressed
}
finally {
	if ($EndOfNightShutDown) {
		shutdown -s -f -t 1	# start shutdown
	}
}

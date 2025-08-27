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
		Clear-Host
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

# Wait until the window is available
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
	[DllImport("user32.dll", SetLastError = true)]
	public static extern bool IsWindow(IntPtr hWnd);
}
"@

			while (-not $mpcProcess.MainWindowHandle -or -not [User32]::IsWindow($mpcProcess.MainWindowHandle)) {
				Start-Sleep -Seconds 1
				$mpcProcess.Refresh() # refresh the process info to update MainWindowHandle
			}

			# Activate the window
			Add-Type -AssemblyName Microsoft.VisualBasic
			[Microsoft.VisualBasic.Interaction]::AppActivate($mpcProcess.Id)

			# Calculate and display total playlist duration
			$shell = New-Object -ComObject Shell.Application
			$totalSeconds = 0
			if ($file2 -and (Test-Path $file2)) {
				$folder = $shell.Namespace((Split-Path $file2))
				$item = $folder.ParseName((Split-Path $file2 -Leaf))
				$duration = $folder.GetDetailsOf($item, 27) # 27 = Video Time Length
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
				$totalSeconds = ($h * 3600 + $m * 60 + $s)
			}
			Write-Host "Movie duration: $totalSeconds seconds"

			# $totalSeconds from file2 has already been determined at this point
			$MovieOffSet = 0
			$waitBeforeCurl = 0

			if ($totalSeconds -gt $MovieTimeOffSet) {
				# Wait until (duration - offset), then run CurlRun2
				$waitBeforeCurl = $totalSeconds - $MovieTimeOffSet
				$MovieOffSet = $MovieTimeOffSet
			}
			else {
				# Movie is shorter than offset: run CurlRun2 as soon as file2 starts
				$waitBeforeCurl = 1 # tiny wait to ensure playback actually started
				$MovieOffSet = $totalSeconds
			}
			Write-Host "Main play wait before CurlRun2: $waitBeforeCurl seconds"
			Start-Sleep -Seconds $waitBeforeCurl
			&$CurlRun2
			Write-Host "Offset duration: $MovieOffSet seconds"
			Start-Sleep -Seconds $MovieOffSet

			# Wait for MPC-HC to exit naturally (end of playlist)
			while (-not $mpcProcess.HasExited) {
				Start-Sleep -Seconds 1
			}

			# Intermission with an Enter keypress interrupt
			$useScreensaver = Test-Path "C:\Windows\System32\MarineAquarium3.scr"
			if ($useScreensaver) {
				Start-Process "C:\Windows\System32\MarineAquarium3.scr"
			}
			# Clear all buffered keypresses before starting
			while ([console]::KeyAvailable) {
				[console]::ReadKey($true) | Out-Null
			}
			$elapsed = 0
			while ($elapsed -lt $Intermission) {
				Clear-Host
				$remaining = $Intermission - $elapsed
				Write-Host "$remaining seconds remaining in intermission..."
				Write-Host "Press & hold Enter key to interrupt..."
				Start-Sleep -Seconds 1
				$elapsed += 1
				if ([console]::KeyAvailable) {
					if ([console]::ReadKey($true).Key -eq 'Enter') { break }
				}
			}
			&$CurlRun3
			if ($useScreensaver) {
				Stop-Process -Name "MarineAquarium3.scr" -ErrorAction SilentlyContinue
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

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

Add-Type -AssemblyName System.Windows.Forms

$rootFolder = "C:\Users\Kurt Schwob\Videos"
$moviesFolder = Join-Path $rootFolder "Movies"
$movieListPath = Join-Path $rootFolder "MovieList.txt"
$saveFolder = $rootFolder

$movieFiles = @(Get-Content -Path $movieListPath)

for ($i=0; $i -lt $movieFiles.Count; $i++) {
    $index = $i + 1
    $videoName = $movieFiles[$i]
    $videoPath = Join-Path $moviesFolder $videoName
    if (-not (Test-Path $videoPath)) {
        Write-Host "File not found: $videoPath - skipping"
        continue
    }
    $process = Start-Process "mpc-hc64.exe" -ArgumentList "`"$videoPath`"" -PassThru
    Start-Sleep -Seconds 5

    $hwnd = 0
    try {
        $hwnd = $process.MainWindowHandle
    } catch {}

    if ($hwnd -eq 0) {
        $windowTitle = $videoName + " - MPC-HC"
        $hwnd = [User32]::FindWindow($null, $windowTitle)
    }

    if ($hwnd -ne 0) {
        [User32]::SetForegroundWindow($hwnd) | Out-Null
        Start-Sleep -Milliseconds 500
        [System.Windows.Forms.SendKeys]::SendWait("%i")   # Alt+I
        Start-Sleep -Milliseconds 500

        $screenshotPath = Join-Path $saveFolder ("Video$index")
        [System.Windows.Forms.SendKeys]::SendWait("$screenshotPath")
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("png")
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Write-Host "Saved screenshot as $screenshotPath.png"
        Start-Sleep -Seconds 3
    } else {
        Write-Host "Could not find MPC-HC window for $videoName"
    }

    Stop-Process -Name "mpc-hc64" -Force
    Start-Sleep -Seconds 1
}
Write-Host "All videos processed."

Add-Type -AssemblyName System.Drawing

$imagePrefix = "Video"
$imageExtension = ".png"

$maxBoxWidth = 1920
$maxBoxHeight = 1080

$maxScaledWidth = 0
$maxScaledHeight = 0

$videoCount = (Get-Content -Path $movieListPath).Count
Write-Host "Total videos listed: $videoCount"

for ($i = 1; $i -le $videoCount; $i++) {
    $imagePath = Join-Path $rootFolder ("$imagePrefix$i$imageExtension")
    if (Test-Path $imagePath) {
        $img = [System.Drawing.Image]::FromFile($imagePath)
        $originalWidth = $img.Width
        $originalHeight = $img.Height
        $img.Dispose()

        $scaleFactor = [Math]::Min($maxBoxWidth / $originalWidth, $maxBoxHeight / $originalHeight)
        $scaledWidth = [math]::Round($originalWidth * $scaleFactor)
        $scaledHeight = [math]::Round($originalHeight * $scaleFactor)

        if ($scaledWidth -gt $maxScaledWidth) { $maxScaledWidth = $scaledWidth }
        if ($scaledHeight -gt $maxScaledHeight) { $maxScaledHeight = $scaledHeight }

        Write-Host "Video$i.png - Original: ${originalWidth}x${originalHeight}, Scaled: ${scaledWidth}x${scaledHeight}"
    } else {
        Write-Host "Missing image: Video$i.png"
    }
}

Write-Host "`nMax scaled width: $maxScaledWidth"
Write-Host "Max scaled height: $maxScaledHeight"

$width = [int]$maxScaledWidth
$height = [int]$maxScaledHeight

$maxBoxWidth = [int]$maxBoxWidth
$maxBoxHeight = [int]$maxBoxHeight

$finalImage = New-Object System.Drawing.Bitmap $maxBoxWidth, $maxBoxHeight
$graphics = [System.Drawing.Graphics]::FromImage($finalImage)
$graphics.Clear([System.Drawing.Color]::Green)

$borderWidth = [math]::Floor(($maxBoxWidth - $width) / 2)
$borderHeight = [math]::Floor(($maxBoxHeight - $height) / 2)

if ($borderWidth -gt 0) {
    $graphics.FillRectangle([System.Drawing.Brushes]::Red, 0, 0, $borderWidth, $maxBoxHeight)
    $graphics.FillRectangle([System.Drawing.Brushes]::Red, $maxBoxWidth - $borderWidth, 0, $borderWidth, $maxBoxHeight)
}

if ($borderHeight -gt 0) {
    $graphics.FillRectangle([System.Drawing.Brushes]::Red, 0, 0, $maxBoxWidth, $borderHeight)
    $graphics.FillRectangle([System.Drawing.Brushes]::Red, 0, $maxBoxHeight - $borderHeight, $maxBoxWidth, $borderHeight)
}

$displayFormatPath = Join-Path $rootFolder "DisplayFormat.png"
$finalImage.Save($displayFormatPath, [System.Drawing.Imaging.ImageFormat]::Png)
$finalImage.Dispose()

Write-Host "Created DisplayFormat.png with size ${maxBoxWidth}x${maxBoxHeight}"

for ($i = 1; $i -le $videoCount; $i++) {
    $imagePath = Join-Path $rootFolder ("$imagePrefix$i$imageExtension")
    if (Test-Path $imagePath) {
        Remove-Item -Path $imagePath -Force
        Write-Host "Deleted image: $imagePath"
    }
}

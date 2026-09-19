$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==============================================="
Write-Host " تصوير كل الشاشات - بدون تغيير main.dart"
Write-Host "==============================================="
Write-Host ""

$flutter = (Get-Command flutter -ErrorAction Stop).Source

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
if ($adbCommand) {
    $adbExe = $adbCommand.Source
} else {
    $adbExe = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
    if (-not (Test-Path $adbExe)) {
        throw "adb غير موجود."
    }
}

if (-not (Test-Path ".\lib\screenshot_main.dart")) {
    throw "lib\screenshot_main.dart غير موجود"
}

$devices = flutter devices --machine | Out-String | ConvertFrom-Json
$device = $devices |
    Where-Object { $_.targetPlatform -like "android*" -and $_.emulator -eq $false } |
    Select-Object -First 1

if (-not $device) {
    $device = $devices |
        Where-Object { $_.targetPlatform -like "android*" } |
        Select-Object -First 1
}

if (-not $device) {
    throw "ماكو جهاز Android ظاهر. نفذ flutter devices وتأكد من USB debugging."
}

Write-Host ("الجهاز: " + $device.name)

$outDir = Join-Path (Get-Location) "screenshots"
if (Test-Path $outDir) {
    Remove-Item $outDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outDir | Out-Null

$logOut = Join-Path (Get-Location) ".capture_flutter.log"
$logErr = Join-Path (Get-Location) ".capture_flutter_error.log"
Remove-Item $logOut,$logErr -ErrorAction SilentlyContinue

Write-Host "جاري تشغيل نسخة التصوير المنفصلة..."

$flutterProcess = Start-Process `
    -FilePath $flutter `
    -ArgumentList @(
        "run",
        "--target=lib/screenshot_main.dart",
        "-d", $device.id
    ) `
    -RedirectStandardOutput $logOut `
    -RedirectStandardError $logErr `
    -PassThru

$packageId = "com.example.oil_distribution_app"

Write-Host "بانتظار تشغيل التطبيق..."
$started = $false
for ($i = 0; $i -lt 180; $i++) {
    Start-Sleep -Seconds 1

    if ($flutterProcess.HasExited) {
        break
    }

    $state = (& $adbExe -s $device.id get-state 2>$null | Out-String).Trim()
    if ($state -ne "device") {
        continue
    }

    $appPid = (& $adbExe -s $device.id shell pidof $packageId 2>$null | Out-String).Trim()
    if ($appPid) {
        $started = $true
        break
    }
}

if (-not $started) {
    Write-Host ""
    Write-Host "تعذر تشغيل نسخة التصوير."
    Write-Host "--- flutter output ---"
    if (Test-Path $logOut) { Get-Content $logOut -Tail 50 }
    if (Test-Path $logErr) { Get-Content $logErr -Tail 50 }
    exit 1
}

Write-Host "اشتغل التطبيق. ننتظر بدء انتقال الشاشات..."
Start-Sleep -Seconds 16

$names = @(
    "00_home",
    "01_login",
    "02_citizen",
    "03_settings",
    "04_admin",
    "05_admin_branches",
    "06_admin_users",
    "07_products",
    "08_reports",
    "09_zain_cash_settings",
    "10_commercial_requests",
    "11_commercial_payments",
    "12_contact_messages",
    "13_admin_ratings",
    "14_internal_messages",
    "15_branch_dashboard",
    "16_branch_stations",
    "17_pending_stations",
    "18_quantity_tracking",
    "19_branch_users",
    "20_station_dashboard",
    "21_station_folders",
    "22_government_stations",
    "23_private_stations",
    "24_stations",
    "25_register_station",
    "26_change_password_request",
    "27_notifications",
    "28_commercial_ad_form",
    "29_commercial_ads",
    "30_my_commercial_ads",
    "31_my_commercial_payments",
    "32_about",
    "33_language",
    "34_contact",
    "35_rating",
    "36_privacy",
    "37_terms"
)

function Save-AdbScreenshot {
    param([string]$FilePath)

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $adbExe
    $psi.Arguments = "-s $($device.id) exec-out screencap -p"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()

    $stream = [System.IO.File]::Create($FilePath)
    try {
        $proc.StandardOutput.BaseStream.CopyTo($stream)
    } finally {
        $stream.Dispose()
    }

    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) {
        throw $proc.StandardError.ReadToEnd()
    }
}

for ($i = 0; $i -lt $names.Count; $i++) {
    $state = (& $adbExe -s $device.id get-state 2>$null | Out-String).Trim()
    if ($state -ne "device") {
        throw "انقطع اتصال الموبايل."
    }

    $file = Join-Path $outDir ($names[$i] + ".png")
    Write-Host ("[" + ($i + 1) + "/" + $names.Count + "] " + $names[$i])
    Save-AdbScreenshot $file

    if ($i -lt ($names.Count - 1)) {
        Start-Sleep -Seconds 5
    }
}

$count = (Get-ChildItem $outDir -Filter "*.png").Count
Write-Host ""
Write-Host "==============================================="
Write-Host ("تم حفظ " + $count + " صورة")
Write-Host ("المجلد: " + $outDir)
Write-Host "==============================================="

try {
    & $adbExe -s $device.id shell am force-stop $packageId | Out-Null
} catch {}

try {
    if (-not $flutterProcess.HasExited) {
        Stop-Process -Id $flutterProcess.Id -Force -ErrorAction SilentlyContinue
    }
} catch {}

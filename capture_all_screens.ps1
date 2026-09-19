$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================"
Write-Host " Oil Distribution App - Capture All Screens"
Write-Host "============================================"
Write-Host ""

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter غير موجود في PATH"
}

# تأكد من وجود integration_test
if (-not (Test-Path ".\integration_test\screenshots_test.dart")) {
    throw "ملف integration_test\screenshots_test.dart غير موجود"
}

# تنظيف مجلد الصور السابق فقط
if (Test-Path ".\screenshots") {
    Remove-Item ".\screenshots" -Recurse -Force
}
New-Item -ItemType Directory -Path ".\screenshots" | Out-Null

Write-Host "جاري البحث عن موبايل Android متصل..."

$devicesJson = flutter devices --machine | Out-String
$devices = $devicesJson | ConvertFrom-Json

$android = $devices |
    Where-Object {
        $_.targetPlatform -like "android*" -and
        $_.emulator -eq $false
    } |
    Select-Object -First 1

if (-not $android) {
    $android = $devices |
        Where-Object { $_.targetPlatform -like "android*" } |
        Select-Object -First 1
}

if (-not $android) {
    throw "ماكو جهاز Android ظاهر. وصل الموبايل وفعل USB debugging ثم نفذ flutter devices."
}

Write-Host ("الجهاز: " + $android.name + "  ID: " + $android.id)
Write-Host ""
Write-Host "جاري تصوير الشاشات تلقائيا..."
Write-Host ""

flutter drive `
  --driver=test_driver/integration_test.dart `
  --target=integration_test/screenshots_test.dart `
  -d $android.id

$driveExit = $LASTEXITCODE
$count = (Get-ChildItem ".\screenshots\*.png" -ErrorAction SilentlyContinue).Count

if ($driveExit -ne 0) {
    Write-Host ""
    Write-Host "============================================"
    Write-Host "فشل التصوير ولم تكتمل العملية."
    Write-Host ("عدد الصور التي حُفظت قبل التوقف: " + $count)
    Write-Host "============================================"
    exit $driveExit
}

if ($count -eq 0) {
    throw "انتهى الاختبار ولكن لم تُحفظ أي صورة."
}

Write-Host ""
Write-Host "============================================"
Write-Host ("تم بنجاح. عدد الصور المحفوظة: " + $count)
Write-Host ("المجلد: " + (Resolve-Path ".\screenshots"))
Write-Host "============================================"

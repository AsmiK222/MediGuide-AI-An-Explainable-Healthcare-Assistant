# =============================================================================
# MediGuide AI - FIX SPACES IN PATH + image_picker
# Run this ONCE in PowerShell, then use X: drive for everything
#
# The error "'D:\Desktop\6th' is not recognized" is caused by the space in
# "6th Sem" - Flutter's Dart SDK cannot handle spaces in project paths.
#
# HOW TO RUN:
#   powershell -ExecutionPolicy Bypass -File "D:\Desktop\6th Sem\SWE\final_flutter_integration\FIX_PATH.ps1"
# =============================================================================

$ROOT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Fix: Spaces in Path + image_picker       " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# =============================================================================
# FIX 1: Replace image_picker with image_picker_web in pubspec.yaml
# image_picker pulls in objective_c (iOS native) which fails with spaces in path
# image_picker_web is web-only, no native hooks, no spaces problem
# =============================================================================
Write-Host ""
Write-Host "[1] Fixing pubspec.yaml (image_picker -> image_picker_web)..." -ForegroundColor Yellow

$pubspec = "$ROOT\pubspec.yaml"
$c = [System.IO.File]::ReadAllText($pubspec)
$orig = $c

$c = $c -replace "  image_picker: \^1\.0\.7", "  image_picker_web: ^4.0.0"
$c = $c -replace "  image_picker: .*", "  image_picker_web: ^4.0.0"

if ($c -ne $orig) {
    [System.IO.File]::WriteAllText($pubspec, $c, [System.Text.Encoding]::UTF8)
    Write-Host "    OK: pubspec.yaml updated" -ForegroundColor Green
} else {
    Write-Host "    Already fixed or image_picker not found" -ForegroundColor DarkGray
}

# =============================================================================
# FIX 2: Update pill_identifier_screen.dart to use image_picker_web
# =============================================================================
Write-Host ""
Write-Host "[2] Fixing image_picker imports in dart files..." -ForegroundColor Yellow

$pilldart = "$ROOT\lib\screens\pill_identifier_screen.dart"
if (Test-Path $pilldart) {
    $c = [System.IO.File]::ReadAllText($pilldart)
    $orig = $c

    # Replace image_picker import with image_picker_web
    $c = $c -replace "import 'package:image_picker/image_picker\.dart';",
                     "import 'package:image_picker_web/image_picker_web.dart';"

    # Replace ImagePicker().pickImage() with ImagePickerWeb.getImageAsWidget / getImageAsBytes
    # The web API is different - use bytes approach
    $c = $c -replace "final ImagePicker _picker = ImagePicker\(\);", ""
    $c = $c -replace "final XFile\? image = await _picker\.pickImage\(source: ImageSource\.gallery\);",
@"
final Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();
"@
    $c = $c -replace "if \(image == null\) return;",
                     "if (imageBytes == null) return;"
    $c = $c -replace "File\(image\.path\)", "imageBytes"

    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($pilldart, $c, [System.Text.Encoding]::UTF8)
        Write-Host "    OK: pill_identifier_screen.dart updated" -ForegroundColor Green
    } else {
        Write-Host "    No image_picker usage found in pill_identifier_screen.dart" -ForegroundColor DarkGray
    }
} else {
    Write-Host "    pill_identifier_screen.dart not found" -ForegroundColor DarkYellow
}

# Also check all other dart files for image_picker imports
Get-ChildItem -Path "$ROOT\lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $c
    $c = $c -replace "import 'package:image_picker/image_picker\.dart';",
                     "import 'package:image_picker_web/image_picker_web.dart';"
    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.Encoding]::UTF8)
        Write-Host "    Fixed image_picker import in: $($_.Name)" -ForegroundColor DarkGray
    }
}

# =============================================================================
# FIX 3: Map project to X: drive (bypasses spaces in path entirely)
# =============================================================================
Write-Host ""
Write-Host "[3] Mapping project to X: drive (fixes space-in-path error)..." -ForegroundColor Yellow

# Remove old mapping if exists
subst X: /d 2>$null
Start-Sleep -Milliseconds 500

# Map X: to the project root
subst X: "D:\Desktop\6th Sem\SWE\final_flutter_integration"

if ($LASTEXITCODE -eq 0) {
    Write-Host "    OK: X: drive mapped to project root" -ForegroundColor Green
} else {
    Write-Host "    subst failed - try manually: subst X: `"D:\Desktop\6th Sem\SWE\final_flutter_integration`"" -ForegroundColor Red
}

# =============================================================================
# INSTRUCTIONS
# =============================================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   Done! Now run Flutter from X: drive:    " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  X:"                                              -ForegroundColor White
Write-Host "  flutter clean"                                   -ForegroundColor White
Write-Host "  flutter pub get"                                 -ForegroundColor White
Write-Host "  flutter run -d chrome"                          -ForegroundColor White
Write-Host ""
Write-Host "  (Always use X: instead of D:\Desktop\6th Sem\...)" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  NOTE: The X: mapping resets on reboot." -ForegroundColor DarkYellow
Write-Host "  Re-run this script each time you restart your PC." -ForegroundColor DarkYellow
Write-Host ""
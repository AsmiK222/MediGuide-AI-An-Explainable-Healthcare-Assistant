# =============================================================================
# MediGuide AI - Fix Import Errors
# Run from: D:\Desktop\6th Sem\SWE\final_flutter_integration
# =============================================================================

$ROOT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"
$LIB  = "$ROOT\lib"

Set-Location $ROOT

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Fixing Import Errors                 " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# PROBLEM 1: pill_identifier_screen.dart and drug_interaction_screen.dart
# use: import '../../lib/api_config.dart';
# FIX:       import '../config/api_config.dart';

# PROBLEM 2: doctor_portal.dart, appointment.dart, chatbot_screen.dart
# use: import '../../../malavika/lib/widgets/chatbot_widget.dart';
# FIX:       import '../widgets/chatbot_widget.dart';

# PROBLEM 3: lib\api_config.dart at root of lib\ (duplicate - delete it)

$fixes = @{
    "pill_identifier_screen.dart" = @{
        "import '../../lib/api_config.dart';" = "import '../config/api_config.dart';"
        "import '../api_config.dart';"         = "import '../config/api_config.dart';"
    }
    "drug_interaction_screen.dart" = @{
        "import '../../lib/api_config.dart';" = "import '../config/api_config.dart';"
        "import '../api_config.dart';"         = "import '../config/api_config.dart';"
    }
    "drug_info_page.dart" = @{
        "import '../../lib/api_config.dart';" = "import '../config/api_config.dart';"
        "import '../api_config.dart';"         = "import '../config/api_config.dart';"
    }
    "doctor_portal.dart" = @{
        "import '../../../malavika/lib/widgets/chatbot_widget.dart';" = "import '../widgets/chatbot_widget.dart';"
        "import '../../widgets/chatbot_widget.dart';"                 = "import '../widgets/chatbot_widget.dart';"
        "import '../../lib/api_config.dart';"                        = "import '../config/api_config.dart';"
        "import '../api_config.dart';"                               = "import '../config/api_config.dart';"
    }
    "appointment.dart" = @{
        "import '../../../malavika/lib/widgets/chatbot_widget.dart';" = "import '../widgets/chatbot_widget.dart';"
        "import '../../widgets/chatbot_widget.dart';"                 = "import '../widgets/chatbot_widget.dart';"
        "import '../../lib/api_config.dart';"                        = "import '../config/api_config.dart';"
        "import '../api_config.dart';"                               = "import '../config/api_config.dart';"
    }
    "chatbot_screen.dart" = @{
        "import '../../../malavika/lib/widgets/chatbot_widget.dart';" = "import '../widgets/chatbot_widget.dart';"
        "import '../../widgets/chatbot_widget.dart';"                 = "import '../widgets/chatbot_widget.dart';"
    }
    "graph_screen.dart" = @{
        "import '../../../malavika/lib/widgets/chatbot_widget.dart';" = "import '../widgets/chatbot_widget.dart';"
        "import '../../lib/api_config.dart';"                        = "import '../config/api_config.dart';"
        "import '../api_config.dart';"                               = "import '../config/api_config.dart';"
    }
    "doctor_detail.dart" = @{
        "import '../../../malavika/lib/widgets/chatbot_widget.dart';" = "import '../widgets/chatbot_widget.dart';"
        "import '../../lib/api_config.dart';"                        = "import '../config/api_config.dart';"
        "import '../api_config.dart';"                               = "import '../config/api_config.dart';"
    }
}

foreach ($filename in $fixes.Keys) {
    $path = "$LIB\screens\$filename"
    if (Test-Path $path) {
        $c = [System.IO.File]::ReadAllText($path)
        $orig = $c
        foreach ($old in $fixes[$filename].Keys) {
            $new = $fixes[$filename][$old]
            $c = $c.Replace($old, $new)
        }
        if ($c -ne $orig) {
            [System.IO.File]::WriteAllText($path, $c, [System.Text.Encoding]::UTF8)
            Write-Host "  Fixed: $filename" -ForegroundColor Green
        } else {
            Write-Host "  No changes needed: $filename" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  Not found (skip): $filename" -ForegroundColor DarkYellow
    }
}

Write-Host ""

# Delete the duplicate lib\api_config.dart at root of lib (keep only config\api_config.dart)
$dup = "$LIB\api_config.dart"
if (Test-Path $dup) {
    Remove-Item $dup -Force
    Write-Host "  Deleted duplicate: lib\api_config.dart (keeping lib\config\api_config.dart)" -ForegroundColor Green
}

Write-Host ""

# Also fix the objective_c / spaces-in-path issue
# This is caused by "6th Sem" having a space. The fix is to use short path for flutter run.
Write-Host "NOTE: The 'D:\Desktop\6th is not recognized' error is because" -ForegroundColor Yellow
Write-Host "your path has spaces ('6th Sem'). Use this command to run Flutter:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  flutter run -d chrome --no-enable-impeller" -ForegroundColor White
Write-Host ""
Write-Host "If it still fails with the spaces error, run:" -ForegroundColor Yellow
Write-Host "  subst X: ""D:\Desktop\6th Sem\SWE\final_flutter_integration""" -ForegroundColor White
Write-Host "  X:" -ForegroundColor White
Write-Host "  flutter run -d chrome" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Imports Fixed - Now Run:             " -ForegroundColor Cyan
Write-Host "   flutter run -d chrome                " -# Run from project ROOT
cd "D:\Desktop\6th Sem\SWE\final_flutter_integration"

# Copy backend_ folder into geshna\SymChecker\ so main.py can find it
Copy-Item "backend_" "geshna\SymChecker\backend_" -Recurse -Force

# Now start Geshna again
cd "geshna\SymChecker"
python -m uvicorn main:app --port 8000 --reloadForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
# =============================================================================
# MediGuide AI - FINAL FIX
# Based on exact file tree - fixes only what is wrong
# 
# HOW TO RUN (copy-paste into PowerShell):
#   powershell -ExecutionPolicy Bypass -File "D:\Desktop\6th Sem\SWE\final_flutter_integration\FINAL_FIX.ps1"
# =============================================================================

$ROOT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"
$LIB  = "$ROOT\lib"

Set-Location $ROOT
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   MediGuide AI - FINAL FIX                " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# =============================================================================
# FIX 1: Move chat_api.dart from lib\screens\ -> lib\services\
# =============================================================================
Write-Host ""
Write-Host "[1] Moving chat_api.dart to lib\services\..." -ForegroundColor Yellow

if (Test-Path "$LIB\screens\chat_api.dart") {
    Copy-Item "$LIB\screens\chat_api.dart" "$LIB\services\chat_api.dart" -Force
    Remove-Item "$LIB\screens\chat_api.dart" -Force
    Write-Host "    OK: moved -> lib\services\chat_api.dart" -ForegroundColor Green
} elseif (Test-Path "$LIB\services\chat_api.dart") {
    Write-Host "    Already in lib\services\chat_api.dart" -ForegroundColor DarkGray
} else {
    @'
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatAPI {
  static const String baseUrl = "http://localhost:8002";

  static Future<String> sendMessage(String message, String language) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'language': language}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? data['response'] ?? 'No response';
    } else {
      throw Exception('Backend error: ${response.statusCode}');
    }
  }
}
'@ | Set-Content "$LIB\services\chat_api.dart" -Encoding UTF8
    Write-Host "    Created: lib\services\chat_api.dart" -ForegroundColor Green
}

# =============================================================================
# FIX 2: Delete junk non-dart files/folders from lib\screens\
# =============================================================================
Write-Host ""
Write-Host "[2] Cleaning junk files from lib\screens\..." -ForegroundColor Yellow

@(
    "$LIB\screens\.dart_tool",
    "$LIB\screens\.idea",
    "$LIB\screens\build",
    "$LIB\screens\android",
    "$LIB\screens\ios"
) | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item $_ -Recurse -Force
        Write-Host "    Deleted folder: $(Split-Path $_ -Leaf)\" -ForegroundColor DarkGray
    }
}

@(
    "$LIB\screens\.flutter-plugins-dependencies",
    "$LIB\screens\.metadata",
    "$LIB\screens\.gitignore",
    "$LIB\screens\analysis_options.yaml",
    "$LIB\screens\devtools_options.yaml",
    "$LIB\screens\pubspec.lock",
    "$LIB\screens\pubspec.yaml",
    "$LIB\screens\symptom_checker.iml",
    "$LIB\screens\README.md"
) | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item $_ -Force
        Write-Host "    Deleted: $(Split-Path $_ -Leaf)" -ForegroundColor DarkGray
    }
}

Write-Host "    Done" -ForegroundColor Green

# =============================================================================
# FIX 3: Delete lib\main_malavika.dart (has broken imports, not used)
# =============================================================================
Write-Host ""
Write-Host "[3] Removing lib\main_malavika.dart..." -ForegroundColor Yellow

if (Test-Path "$LIB\main_malavika.dart") {
    Remove-Item "$LIB\main_malavika.dart" -Force
    Write-Host "    Deleted" -ForegroundColor Green
} else {
    Write-Host "    Already gone" -ForegroundColor DarkGray
}

# =============================================================================
# FIX 4: Fix port numbers in all dart files
# =============================================================================
Write-Host ""
Write-Host "[4] Fixing port numbers..." -ForegroundColor Yellow

Get-ChildItem -Path $LIB -Filter "*.dart" -Recurse | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $c

    # chatbot_widget.dart: default backendUrl 8000 -> 8002
    $c = $c -replace "this\.backendUrl = 'http://localhost:8000'",  "this.backendUrl = 'http://localhost:8002'"

    # chat_api.dart: 127.0.0.1:8000 -> localhost:8002
    $c = $c -replace 'static const String baseUrl = "http://127\.0\.0\.1:8000"', 'static const String baseUrl = "http://localhost:8002"'
    $c = $c -replace "static const String baseUrl = 'http://127\.0\.0\.1:8000'", "static const String baseUrl = 'http://localhost:8002'"

    # doctor_portal / appointment: apiUrl() returning 8000 -> 8002
    $c = $c -replace 'return "http://localhost:8000";',    'return "http://localhost:8002";'
    $c = $c -replace 'return "http://10\.0\.2\.2:8000";', 'return "http://10.0.2.2:8002";'

    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.Encoding]::UTF8)
        Write-Host "    Port fixed: $($_.Name)" -ForegroundColor DarkGray
    }
}
Write-Host "    Done" -ForegroundColor Green

# =============================================================================
# FIX 5: Fix import paths in all dart files
# =============================================================================
Write-Host ""
Write-Host "[5] Fixing import paths..." -ForegroundColor Yellow

Get-ChildItem -Path $LIB -Filter "*.dart" -Recurse | ForEach-Object {
    $c = [System.IO.File]::ReadAllText($_.FullName)
    $orig = $c

    # chat_api imported without path (was in same folder before)
    $c = $c -replace "import 'chat_api\.dart';",    "import '../services/chat_api.dart';"
    $c = $c -replace "import '\./chat_api\.dart';", "import '../services/chat_api.dart';"

    # api_config wrong paths
    $c = $c -replace "import '\.\.\/api_config\.dart';",            "import '../config/api_config.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/api_config\.dart';",      "import '../config/api_config.dart';"
    $c = $c -replace "import 'api_config\.dart';",                  "import '../config/api_config.dart';"
    $c = $c -replace "import '\.\.\/lib\/api_config\.dart';",       "import '../config/api_config.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/lib\/api_config\.dart';", "import '../config/api_config.dart';"

    # chatbot_widget wrong depth
    $c = $c -replace "import '\.\.\/\.\.\/widgets\/chatbot_widget\.dart';",                      "import '../widgets/chatbot_widget.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/\.\.\/widgets\/chatbot_widget\.dart';",                "import '../widgets/chatbot_widget.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/\.\.\/malavika\/lib\/widgets\/chatbot_widget\.dart';", "import '../widgets/chatbot_widget.dart';"

    # services wrong depth
    $c = $c -replace "import '\.\.\/\.\.\/services\/symptom_api\.dart';", "import '../services/symptom_api.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/services\/disease_api\.dart';", "import '../services/disease_api.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/services\/chat_api\.dart';",    "import '../services/chat_api.dart';"

    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($_.FullName, $c, [System.Text.Encoding]::UTF8)
        Write-Host "    Import fixed: $($_.Name)" -ForegroundColor DarkGray
    }
}
Write-Host "    Done" -ForegroundColor Green

# =============================================================================
# FINAL CHECK
# =============================================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   FINAL STATUS CHECK                      " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$required = [ordered]@{
    "lib\main.dart"                                    = "App Entry Point"
    "lib\config\api_config.dart"                       = "API Config (ports)"
    "lib\providers\symptom_provider.dart"              = "Symptom Provider"
    "lib\constants\symptoms.dart"                      = "Symptoms List"
    "lib\services\symptom_api.dart"                    = "Symptom API"
    "lib\services\disease_api.dart"                    = "Disease API"
    "lib\services\chat_api.dart"                       = "Chat API"
    "lib\widgets\chatbot_widget.dart"                  = "Chatbot Widget"
    "lib\widgets\backend_status_indicator.dart"        = "Status Widget"
    "lib\screens\home_screen.dart"                     = "Home Screen"
    "lib\screens\age_gender_screen.dart"               = "Age/Gender  [Geshna]"
    "lib\screens\symptom_selection_screen.dart"        = "Symptom Select  [Geshna]"
    "lib\screens\symptom_selection_method_screen.dart" = "Method Select  [Geshna]"
    "lib\screens\anatomy_symptom_selector.dart"        = "3D Anatomy  [Geshna]"
    "lib\screens\results_screen.dart"                  = "Results  [Geshna]"
    "lib\screens\condition_screens.dart"               = "Conditions  [Geshna]"
    "lib\screens\disease_detail_screen.dart"           = "Disease Detail  [Geshna]"
    "lib\screens\pill_identifier_screen.dart"          = "Pill ID  [Vibhu]"
    "lib\screens\drug_interaction_screen.dart"         = "Drug Interaction  [Vibhu]"
    "lib\screens\drug_info_page.dart"                  = "Drug Info  [Vibhu]"
    "lib\screens\doctor_portal.dart"                   = "Doctors  [Malavika]"
    "lib\screens\appointment.dart"                     = "Appointments  [Malavika]"
    "lib\screens\chatbot_screen.dart"                  = "Chat Screen  [Malavika]"
    "lib\screens\graph_screen.dart"                    = "Graph  [Malavika]"
}

$allOk = $true
foreach ($path in $required.Keys) {
    $label = $required[$path]
    if (Test-Path "$ROOT\$path") {
        Write-Host ("  {0,-44} OK" -f $label) -ForegroundColor Green
    } else {
        Write-Host ("  {0,-44} !! MISSING !!" -f $label) -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ""
if ($allOk) {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  ALL FILES PRESENT                        " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "START BACKENDS (3 separate terminals):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Terminal 1 - Geshna (port 8000):" -ForegroundColor White
    Write-Host "    cd `"$ROOT\backend\symptom_checker`"" -ForegroundColor Gray
    Write-Host "    uvicorn main:app --reload --port 8000" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Terminal 2 - Vibhu (port 8001):" -ForegroundColor White
    Write-Host "    cd `"$ROOT\backend\drug_intelligence\backend`"" -ForegroundColor Gray
    Write-Host "    uvicorn main:app --reload --port 8001" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Terminal 3 - Malavika (port 8002):" -ForegroundColor White
    Write-Host "    cd `"$ROOT\backend\doctor_portal`"" -ForegroundColor Gray
    Write-Host "    python load_doctors_from_csv.py   # run ONCE first" -ForegroundColor DarkYellow
    Write-Host "    python create_hospitals.py        # run ONCE first" -ForegroundColor DarkYellow
    Write-Host "    uvicorn main:app --reload --port 8002" -ForegroundColor Gray
    Write-Host ""
    Write-Host "THEN RUN FLUTTER:" -ForegroundColor Cyan
    Write-Host "    flutter clean" -ForegroundColor White
    Write-Host "    flutter pub get" -ForegroundColor White
    Write-Host "    flutter run -d chrome" -ForegroundColor White
} else {
    Write-Host "  Some files are missing (marked red above)." -ForegroundColor Yellow
    Write-Host "  Tell the relevant team member to share that file." -ForegroundColor Yellow
}
Write-Host ""
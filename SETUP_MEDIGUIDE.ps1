# =============================================================================
# MediGuide AI - One-Click Setup Script
# Save to: D:\Desktop\6th Sem\SWE\final_flutter_integration\SETUP_MEDIGUIDE.ps1
# Run:     .\SETUP_MEDIGUIDE.ps1
# =============================================================================

$ROOT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"
$LIB  = "$ROOT\lib"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   MediGuide AI - Integration Setup     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $ROOT

# STEP 1 - Rename lib_ to lib
Write-Host "STEP 1: Fixing lib_ folder name..." -ForegroundColor Yellow

if (Test-Path "$ROOT\lib_") {
    if (Test-Path "$ROOT\lib") {
        Write-Host "  lib/ exists - backing up lib_ as lib_backup" -ForegroundColor DarkYellow
        if (Test-Path "$ROOT\lib_backup") {
            Remove-Item "$ROOT\lib_backup" -Recurse -Force
        }
        Rename-Item "$ROOT\lib_" "lib_backup" -Force
    } else {
        Rename-Item "$ROOT\lib_" "lib" -Force
        Write-Host "  lib_ renamed to lib" -ForegroundColor Green
    }
} elseif (Test-Path "$ROOT\lib") {
    Write-Host "  lib/ already exists - skipping" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Path "$ROOT\lib" | Out-Null
    Write-Host "  Created fresh lib/ folder" -ForegroundColor Green
}

Write-Host ""

# STEP 2 - Create subfolders
Write-Host "STEP 2: Creating lib/ subfolders..." -ForegroundColor Yellow

$folders = @(
    "$LIB\config",
    "$LIB\constants",
    "$LIB\providers",
    "$LIB\services",
    "$LIB\screens",
    "$LIB\widgets"
)

foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
    }
    Write-Host "  OK: $($f.Replace($ROOT,''))" -ForegroundColor DarkGray
}

Write-Host ""

# STEP 3 - Write main.dart
Write-Host "STEP 3: Writing main.dart..." -ForegroundColor Yellow

$mainDart = "import 'package:flutter/material.dart';" + [Environment]::NewLine
$mainDart += "import 'package:flutter/services.dart';" + [Environment]::NewLine
$mainDart += "import 'package:google_fonts/google_fonts.dart';" + [Environment]::NewLine
$mainDart += "import 'package:provider/provider.dart';" + [Environment]::NewLine
$mainDart += "import 'providers/symptom_provider.dart';" + [Environment]::NewLine
$mainDart += "import 'screens/home_screen.dart';" + [Environment]::NewLine
$mainDart += "" + [Environment]::NewLine
$mainDart += "void main() {" + [Environment]::NewLine
$mainDart += "  WidgetsFlutterBinding.ensureInitialized();" + [Environment]::NewLine
$mainDart += "  try {" + [Environment]::NewLine
$mainDart += "    SystemChrome.setSystemUIOverlayStyle(" + [Environment]::NewLine
$mainDart += "      const SystemUiOverlayStyle(" + [Environment]::NewLine
$mainDart += "        statusBarColor: Colors.transparent," + [Environment]::NewLine
$mainDart += "        statusBarIconBrightness: Brightness.dark," + [Environment]::NewLine
$mainDart += "      )," + [Environment]::NewLine
$mainDart += "    );" + [Environment]::NewLine
$mainDart += "  } catch (e) {" + [Environment]::NewLine
$mainDart += "    debugPrint('SystemChrome skipped');" + [Environment]::NewLine
$mainDart += "  }" + [Environment]::NewLine
$mainDart += "  runApp(const MediGuideApp());" + [Environment]::NewLine
$mainDart += "}" + [Environment]::NewLine
$mainDart += "" + [Environment]::NewLine
$mainDart += "class MediGuideApp extends StatelessWidget {" + [Environment]::NewLine
$mainDart += "  const MediGuideApp({super.key});" + [Environment]::NewLine
$mainDart += "  @override" + [Environment]::NewLine
$mainDart += "  Widget build(BuildContext context) {" + [Environment]::NewLine
$mainDart += "    return MultiProvider(" + [Environment]::NewLine
$mainDart += "      providers: [" + [Environment]::NewLine
$mainDart += "        ChangeNotifierProvider(create: (_) => SymptomProvider())," + [Environment]::NewLine
$mainDart += "      ]," + [Environment]::NewLine
$mainDart += "      child: MaterialApp(" + [Environment]::NewLine
$mainDart += "        title: 'MediGuide AI'," + [Environment]::NewLine
$mainDart += "        debugShowCheckedModeBanner: false," + [Environment]::NewLine
$mainDart += "        theme: ThemeData(" + [Environment]::NewLine
$mainDart += "          useMaterial3: true," + [Environment]::NewLine
$mainDart += "          colorScheme: ColorScheme.fromSeed(" + [Environment]::NewLine
$mainDart += "            seedColor: const Color(0xFF2563EB)," + [Environment]::NewLine
$mainDart += "            brightness: Brightness.light," + [Environment]::NewLine
$mainDart += "          )," + [Environment]::NewLine
$mainDart += "          textTheme: GoogleFonts.interTextTheme()," + [Environment]::NewLine
$mainDart += "          scaffoldBackgroundColor: const Color(0xFFF9FAFB)," + [Environment]::NewLine
$mainDart += "          appBarTheme: const AppBarTheme(" + [Environment]::NewLine
$mainDart += "            elevation: 0," + [Environment]::NewLine
$mainDart += "            backgroundColor: Colors.transparent," + [Environment]::NewLine
$mainDart += "            foregroundColor: Color(0xFF111827)," + [Environment]::NewLine
$mainDart += "          )," + [Environment]::NewLine
$mainDart += "        )," + [Environment]::NewLine
$mainDart += "        home: const MediGuideHomeScreen()," + [Environment]::NewLine
$mainDart += "      )," + [Environment]::NewLine
$mainDart += "    );" + [Environment]::NewLine
$mainDart += "  }" + [Environment]::NewLine
$mainDart += "}" + [Environment]::NewLine

[System.IO.File]::WriteAllText("$LIB\main.dart", $mainDart, [System.Text.Encoding]::UTF8)
Write-Host "  Written: lib\main.dart" -ForegroundColor Green
Write-Host ""

# STEP 4 - Write config/api_config.dart
Write-Host "STEP 4: Writing config/api_config.dart..." -ForegroundColor Yellow

$apiConfig = "// All backend URLs in one place" + [Environment]::NewLine
$apiConfig += "// Geshna -> port 8000 | Vibhu -> port 8001 | Malavika -> port 8002" + [Environment]::NewLine
$apiConfig += "class ApiConfig {" + [Environment]::NewLine
$apiConfig += "  static const String symptomBase = 'http://localhost:8000';" + [Environment]::NewLine
$apiConfig += "  static const String pillBase    = 'http://localhost:8001';" + [Environment]::NewLine
$apiConfig += "  static const String doctorBase  = 'http://localhost:8002';" + [Environment]::NewLine
$apiConfig += "" + [Environment]::NewLine
$apiConfig += "  // Vibhu endpoints" + [Environment]::NewLine
$apiConfig += "  static String get pillIdentify    => pillBase + '/identify_pill';" + [Environment]::NewLine
$apiConfig += "  static String drugInfo(String n)  => pillBase + '/drug_info/' + n;" + [Environment]::NewLine
$apiConfig += "  static String get drugInteraction => pillBase + '/check_interaction';" + [Environment]::NewLine
$apiConfig += "  static String get drugList        => pillBase + '/drugs/list';" + [Environment]::NewLine
$apiConfig += "  static String get askDrug         => pillBase + '/ask_drug';" + [Environment]::NewLine
$apiConfig += "  static String get baseUrl         => pillBase;" + [Environment]::NewLine
$apiConfig += "" + [Environment]::NewLine
$apiConfig += "  // Malavika endpoints" + [Environment]::NewLine
$apiConfig += "  static String get doctors         => doctorBase + '/doctors/';" + [Environment]::NewLine
$apiConfig += "  static String get hospitals       => doctorBase + '/doctors/hospitals';" + [Environment]::NewLine
$apiConfig += "  static String get bookAppointment => doctorBase + '/doctors/appointments';" + [Environment]::NewLine
$apiConfig += "  static String get appointments    => doctorBase + '/appointments';" + [Environment]::NewLine
$apiConfig += "  static String get chat            => doctorBase + '/chat';" + [Environment]::NewLine
$apiConfig += "  static String get translate       => doctorBase + '/translate';" + [Environment]::NewLine
$apiConfig += "}" + [Environment]::NewLine

[System.IO.File]::WriteAllText("$LIB\config\api_config.dart", $apiConfig, [System.Text.Encoding]::UTF8)
Write-Host "  Written: lib\config\api_config.dart" -ForegroundColor Green
Write-Host ""

# STEP 5 - Move chatbot_widget from root /widgets/ to lib/widgets/
Write-Host "STEP 5: Moving chatbot_widget.dart into lib/widgets/..." -ForegroundColor Yellow

$widgetSrc = "$ROOT\widgets\chatbot_widget.dart"
$widgetDst = "$LIB\widgets\chatbot_widget.dart"

if (Test-Path $widgetSrc) {
    Copy-Item $widgetSrc $widgetDst -Force
    $c = [System.IO.File]::ReadAllText($widgetDst)
    $c = $c -replace "this\.backendUrl = 'http://localhost:8000'", "this.backendUrl = 'http://localhost:8002'"
    $c = $c -replace "this\.backendUrl = 'http://10\.0\.2\.2:8000'", "this.backendUrl = 'http://10.0.2.2:8002'"
    [System.IO.File]::WriteAllText($widgetDst, $c, [System.Text.Encoding]::UTF8)
    Write-Host "  chatbot_widget.dart moved + port fixed 8000->8002" -ForegroundColor Green
} else {
    Write-Host "  WARNING: root\widgets\chatbot_widget.dart not found - skipping" -ForegroundColor DarkYellow
}

Write-Host ""

# STEP 6 - Fix imports and ports in all screen files
Write-Host "STEP 6: Fixing imports and ports in screens..." -ForegroundColor Yellow

$screenFiles = Get-ChildItem -Path "$LIB\screens" -Filter "*.dart" -ErrorAction SilentlyContinue

foreach ($file in $screenFiles) {
    $c = [System.IO.File]::ReadAllText($file.FullName)
    $orig = $c
    $c = $c -replace "import '\.\./api_config\.dart';", "import '../config/api_config.dart';"
    $c = $c -replace "import 'package:final_flutter_integration/api_config\.dart';", "import '../config/api_config.dart';"
    $c = $c -replace 'return "http://localhost:8000";', 'return "http://localhost:8002";'
    $c = $c -replace 'return "http://10\.0\.2\.2:8000";', 'return "http://10.0.2.2:8002";'
    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($file.FullName, $c, [System.Text.Encoding]::UTF8)
        Write-Host "  Fixed: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""

# STEP 7 - Update pubspec.yaml
Write-Host "STEP 7: Writing pubspec.yaml..." -ForegroundColor Yellow

$pubspec = "name: mediguide_ai" + [Environment]::NewLine
$pubspec += "description: MediGuide AI - Geshna + Vibhu + Malavika" + [Environment]::NewLine
$pubspec += "publish_to: 'none'" + [Environment]::NewLine
$pubspec += "version: 1.0.0+1" + [Environment]::NewLine
$pubspec += "" + [Environment]::NewLine
$pubspec += "environment:" + [Environment]::NewLine
$pubspec += "  sdk: '>=3.0.0 <4.0.0'" + [Environment]::NewLine
$pubspec += "" + [Environment]::NewLine
$pubspec += "dependencies:" + [Environment]::NewLine
$pubspec += "  flutter:" + [Environment]::NewLine
$pubspec += "    sdk: flutter" + [Environment]::NewLine
$pubspec += "  provider: ^6.1.2" + [Environment]::NewLine
$pubspec += "  http: ^1.2.0" + [Environment]::NewLine
$pubspec += "  image_picker: ^1.0.7" + [Environment]::NewLine
$pubspec += "  google_fonts: ^6.2.1" + [Environment]::NewLine
$pubspec += "  cupertino_icons: ^1.0.6" + [Environment]::NewLine
$pubspec += "" + [Environment]::NewLine
$pubspec += "dev_dependencies:" + [Environment]::NewLine
$pubspec += "  flutter_test:" + [Environment]::NewLine
$pubspec += "    sdk: flutter" + [Environment]::NewLine
$pubspec += "  flutter_lints: ^3.0.0" + [Environment]::NewLine
$pubspec += "" + [Environment]::NewLine
$pubspec += "flutter:" + [Environment]::NewLine
$pubspec += "  uses-material-design: true" + [Environment]::NewLine

[System.IO.File]::WriteAllText("$ROOT\pubspec.yaml", $pubspec, [System.Text.Encoding]::UTF8)
Write-Host "  pubspec.yaml written" -ForegroundColor Green
Write-Host ""

# STEP 8 - flutter clean + pub get
Write-Host "STEP 8: flutter clean..." -ForegroundColor Yellow
flutter clean
Write-Host ""
Write-Host "STEP 8: flutter pub get..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# DONE
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   AUTOMATED STEPS COMPLETE             " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "MANUAL: Copy these files from mediguide_complete into lib\" -ForegroundColor Red
Write-Host ""
Write-Host "  lib\constants\symptoms.dart" -ForegroundColor White
Write-Host "  lib\providers\symptom_provider.dart" -ForegroundColor White
Write-Host "  lib\services\symptom_api.dart" -ForegroundColor White
Write-Host "  lib\services\disease_api.dart" -ForegroundColor White
Write-Host "  lib\screens\home_screen.dart" -ForegroundColor White
Write-Host "  lib\screens\age_gender_screen.dart" -ForegroundColor White
Write-Host "  lib\screens\anatomy_symptom_selector.dart" -ForegroundColor White
Write-Host "  lib\screens\symptom_selection_method_screen.dart" -ForegroundColor White
Write-Host "  lib\screens\symptom_selection_screen.dart" -ForegroundColor White
Write-Host "  lib\screens\results_screen.dart" -ForegroundColor White
Write-Host "  lib\screens\condition_screens.dart" -ForegroundColor White
Write-Host "  lib\screens\disease_detail_screen.dart" + [Environment]::NewLine
Write-Host "  lib\widgets\backend_status_indicator.dart" -ForegroundColor White
Write-Host "  lib\widgets\loading_indicator.dart" -ForegroundColor White
Write-Host "  lib\widgets\prediction_card.dart" -ForegroundColor White
Write-Host "  lib\widgets\symptom_chip.dart" -ForegroundColor White
Write-Host ""
Write-Host "THEN run 4 terminals:" -ForegroundColor Cyan
Write-Host "  T1: cd geshna\SymChecker && python -m uvicorn main:app --port 8000 --reload" -ForegroundColor White
Write-Host "  T2: cd vibhu\person2_drug_intelligence\backend && python -m uvicorn main:app --port 8001 --reload" -ForegroundColor White
Write-Host "  T3: cd malavika\backend && python -m uvicorn main:app --port 8002 --reload" -ForegroundColor White
Write-Host "  T4: flutter run -d chrome" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
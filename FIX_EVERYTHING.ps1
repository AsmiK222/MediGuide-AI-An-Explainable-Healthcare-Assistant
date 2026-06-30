# =============================================================================
# MediGuide AI - FIX EVERYTHING FINAL
# Fixes:
#   1. lib\main.dart got overwritten with wrong content - restore it
#   2. Flutter SDK path also has spaces - subst it to Y: drive
#   3. Add Y:\bin to PATH so 'flutter' command works from X:
#
# HOW TO RUN:
#   powershell -ExecutionPolicy Bypass -File "D:\Desktop\6th Sem\SWE\final_flutter_integration\FIX_EVERYTHING.ps1"
# =============================================================================

$PROJECT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"
$FLUTTER  = "D:\Desktop\6th Sem\SWE\flutter_project_dart\flutter"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   MediGuide AI - FIX EVERYTHING FINAL     " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# =============================================================================
# FIX 1: Restore lib\main.dart (it got overwritten with wrong content)
# =============================================================================
Write-Host ""
Write-Host "[1] Restoring correct lib\main.dart..." -ForegroundColor Yellow

$correctMain = @'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/symptom_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (e) {
    debugPrint('SystemChrome skipped');
  }
  runApp(const MediGuideApp());
}

class MediGuideApp extends StatelessWidget {
  const MediGuideApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
      ],
      child: MaterialApp(
        title: 'MediGuide AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF111827),
          ),
        ),
        home: const MediGuideHomeScreen(),
      ),
    );
  }
}
'@

Set-Content "$PROJECT\lib\main.dart" $correctMain -Encoding UTF8
Write-Host "    OK: lib\main.dart restored" -ForegroundColor Green

# =============================================================================
# FIX 2: Map Flutter SDK to Y: drive (its path also has spaces)
# =============================================================================
Write-Host ""
Write-Host "[2] Mapping Flutter SDK to Y: drive..." -ForegroundColor Yellow

subst Y: /d 2>$null
Start-Sleep -Milliseconds 300
subst Y: $FLUTTER

if (Test-Path "Y:\bin\flutter.bat") {
    Write-Host "    OK: Y: drive mapped to Flutter SDK" -ForegroundColor Green
} else {
    Write-Host "    WARNING: Y:\bin\flutter.bat not found" -ForegroundColor Red
    Write-Host "    Your Flutter SDK may be at a different path." -ForegroundColor Red
    Write-Host "    Check where flutter.exe is and update FLUTTER variable in this script." -ForegroundColor Red
}

# =============================================================================
# FIX 3: Map project to X: drive
# =============================================================================
Write-Host ""
Write-Host "[3] Mapping project to X: drive..." -ForegroundColor Yellow

subst X: /d 2>$null
Start-Sleep -Milliseconds 300
subst X: $PROJECT

if (Test-Path "X:\lib\main.dart") {
    Write-Host "    OK: X: drive mapped to project" -ForegroundColor Green
} else {
    Write-Host "    WARNING: X:\lib\main.dart not found" -ForegroundColor Red
}

# =============================================================================
# FIX 4: Add Y:\bin to PATH for this session so 'flutter' works from X:
# =============================================================================
Write-Host ""
Write-Host "[4] Adding Y:\bin to PATH for this session..." -ForegroundColor Yellow

$env:PATH = "Y:\bin;" + $env:PATH
Write-Host "    OK: Y:\bin added to PATH" -ForegroundColor Green

# =============================================================================
# VERIFY main.dart is correct
# =============================================================================
Write-Host ""
Write-Host "[5] Verifying lib\main.dart content..." -ForegroundColor Yellow

$mainContent = Get-Content "$PROJECT\lib\main.dart" -Raw
if ($mainContent -match "screens/home_screen.dart" -and $mainContent -match "MediGuideHomeScreen") {
    Write-Host "    OK: main.dart imports screens/home_screen.dart correctly" -ForegroundColor Green
} else {
    Write-Host "    ERROR: main.dart still has wrong content!" -ForegroundColor Red
}

# =============================================================================
# DONE - Print run instructions
# =============================================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   Ready! Run these commands NOW:          " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  X:"                        -ForegroundColor White
Write-Host "  flutter clean"             -ForegroundColor White
Write-Host "  flutter pub get"           -ForegroundColor White
Write-Host "  flutter run -d chrome"     -ForegroundColor White
Write-Host ""
Write-Host "NOTE: X: and Y: reset on reboot." -ForegroundColor DarkYellow
Write-Host "Re-run this script after each restart." -ForegroundColor DarkYellow
Write-Host ""
Write-Host "IMPORTANT - Start backends first (3 terminals):" -ForegroundColor Cyan
Write-Host "  cd `"$PROJECT\backend\symptom_checker`"  && uvicorn main:app --reload --port 8000" -ForegroundColor Gray
Write-Host "  cd `"$PROJECT\backend\drug_intelligence\backend`" && uvicorn main:app --reload --port 8001" -ForegroundColor Gray
Write-Host "  cd `"$PROJECT\backend\doctor_portal`"    && uvicorn main:app --reload --port 8002" -ForegroundColor Gray
Write-Host ""
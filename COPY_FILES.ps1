# =============================================================================
# MediGuide AI - Copy files from within your own project
# All source files already exist in geshna\ and lib_\ folders
# Run from: D:\Desktop\6th Sem\SWE\final_flutter_integration
# =============================================================================

$ROOT    = "D:\Desktop\6th Sem\SWE\final_flutter_integration"
$LIB     = "$ROOT\lib"
$GESHNA  = "$ROOT\geshna\SymChecker\flutter_app\lib"
$LIB_OLD = "$ROOT\lib_"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   MediGuide AI - Copy Files            " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $ROOT

# ── FROM GESHNA'S flutter_app/lib/ ───────────────────────────────────────────

Write-Host "Copying from geshna\SymChecker\flutter_app\lib\" -ForegroundColor Yellow
Write-Host ""

# constants
$src = "$GESHNA\constants\symptoms.dart"
if (Test-Path $src) {
    Copy-Item $src "$LIB\constants\symptoms.dart" -Force
    Write-Host "  OK: lib\constants\symptoms.dart" -ForegroundColor Green
} else {
    Write-Host "  MISSING: $src" -ForegroundColor Red
}

# providers
$src = "$GESHNA\providers\symptom_provider.dart"
if (Test-Path $src) {
    Copy-Item $src "$LIB\providers\symptom_provider.dart" -Force
    Write-Host "  OK: lib\providers\symptom_provider.dart" -ForegroundColor Green
} else {
    Write-Host "  MISSING: $src" -ForegroundColor Red
}

# services
$src = "$GESHNA\services\symptom_api.dart"
if (Test-Path $src) {
    Copy-Item $src "$LIB\services\symptom_api.dart" -Force
    # Fix hardcoded 127.0.0.1 -> localhost
    $c = [System.IO.File]::ReadAllText("$LIB\services\symptom_api.dart")
    $c = $c -replace "static const String baseUrl = 'http://127\.0\.0\.1:8000'.*", "static const String baseUrl = 'http://localhost:8000';"
    [System.IO.File]::WriteAllText("$LIB\services\symptom_api.dart", $c, [System.Text.Encoding]::UTF8)
    Write-Host "  OK: lib\services\symptom_api.dart (port fixed)" -ForegroundColor Green
} else {
    Write-Host "  MISSING: $src" -ForegroundColor Red
}

$src = "$GESHNA\services\disease_api.dart"
if (Test-Path $src) {
    Copy-Item $src "$LIB\services\disease_api.dart" -Force
    $c = [System.IO.File]::ReadAllText("$LIB\services\disease_api.dart")
    $c = $c -replace "static const String baseUrl = 'http://127\.0\.0\.1:8000'.*", "static const String baseUrl = 'http://localhost:8000';"
    [System.IO.File]::WriteAllText("$LIB\services\disease_api.dart", $c, [System.Text.Encoding]::UTF8)
    Write-Host "  OK: lib\services\disease_api.dart (port fixed)" -ForegroundColor Green
} else {
    Write-Host "  MISSING: $src" -ForegroundColor Red
}

# Geshna screens
$geshnaScreens = @(
    "age_gender_screen.dart",
    "anatomy_symptom_selector.dart",
    "symptom_selection_method_screen.dart",
    "symptom_selection_screen.dart",
    "results_screen.dart",
    "condition_screens.dart",
    "disease_detail_screen.dart",
    "home_screen.dart"
)

Write-Host ""
Write-Host "Copying Geshna screens..." -ForegroundColor Yellow

foreach ($screen in $geshnaScreens) {
    $src = "$GESHNA\screens\$screen"
    if (Test-Path $src) {
        Copy-Item $src "$LIB\screens\$screen" -Force
        Write-Host "  OK: lib\screens\$screen" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $src" -ForegroundColor Red
    }
}

# Geshna widgets
$geshnaWidgets = @(
    "backend_status_indicator.dart",
    "loading_indicator.dart",
    "prediction_card.dart",
    "symptom_chip.dart"
)

Write-Host ""
Write-Host "Copying Geshna widgets..." -ForegroundColor Yellow

foreach ($widget in $geshnaWidgets) {
    $src = "$GESHNA\widgets\$widget"
    if (Test-Path $src) {
        Copy-Item $src "$LIB\widgets\$widget" -Force
        Write-Host "  OK: lib\widgets\$widget" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $src" -ForegroundColor Red
    }
}

# ── FIX IMPORTS IN ALL COPIED FILES ──────────────────────────────────────────

Write-Host ""
Write-Host "Fixing imports in all lib\ files..." -ForegroundColor Yellow

$allDart = Get-ChildItem -Path $LIB -Filter "*.dart" -Recurse

foreach ($file in $allDart) {
    $c = [System.IO.File]::ReadAllText($file.FullName)
    $orig = $c

    # Fix prediction_card wrong service import depth
    $c = $c -replace "import '\.\./\.\.\/services\/symptom_api\.dart';", "import '../services/symptom_api.dart';"
    $c = $c -replace "import '\.\.\/\.\.\/services\/disease_api\.dart';", "import '../services/disease_api.dart';"

    # Fix api_config import path
    $c = $c -replace "import '\.\./api_config\.dart';", "import '../config/api_config.dart';"
    $c = $c -replace "import 'package:final_flutter_integration/api_config\.dart';", "import '../config/api_config.dart';"

    # Fix chatbot_widget import from screens
    $c = $c -replace "import '\.\.\/\.\.\/widgets\/chatbot_widget\.dart';", "import '../widgets/chatbot_widget.dart';"

    # Fix doctor/appointment port 8000 -> 8002
    $c = $c -replace 'return "http://localhost:8000";', 'return "http://localhost:8002";'
    $c = $c -replace 'return "http://10\.0\.2\.2:8000";', 'return "http://10.0.2.2:8002";'

    # Fix home_screen - remove condition_screens import if it's Geshna's original home
    # (our unified home_screen.dart already has the right imports)

    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($file.FullName, $c, [System.Text.Encoding]::UTF8)
        Write-Host "  Fixed imports: $($file.Name)" -ForegroundColor DarkGray
    }
}

# ── NOW OVERWRITE home_screen.dart with unified version ───────────────────────

Write-Host ""
Write-Host "Writing unified home_screen.dart..." -ForegroundColor Yellow

$homeScreen = "import 'package:flutter/material.dart';" + [Environment]::NewLine
$homeScreen += "import 'package:provider/provider.dart';" + [Environment]::NewLine
$homeScreen += "import '../providers/symptom_provider.dart';" + [Environment]::NewLine
$homeScreen += "import '../widgets/backend_status_indicator.dart';" + [Environment]::NewLine
$homeScreen += "import 'age_gender_screen.dart';" + [Environment]::NewLine
$homeScreen += "import 'condition_screens.dart';" + [Environment]::NewLine
$homeScreen += "import 'pill_identifier_screen.dart';" + [Environment]::NewLine
$homeScreen += "import 'drug_interaction_screen.dart';" + [Environment]::NewLine
$homeScreen += "import 'drug_info_page.dart';" + [Environment]::NewLine
$homeScreen += "import 'doctor_portal.dart';" + [Environment]::NewLine
$homeScreen += "import 'appointment.dart';" + [Environment]::NewLine
$homeScreen += "import 'chatbot_screen.dart';" + [Environment]::NewLine
$homeScreen += "import 'graph_screen.dart';" + [Environment]::NewLine
$homeScreen += "" + [Environment]::NewLine
$homeScreen += "class MediGuideHomeScreen extends StatefulWidget {" + [Environment]::NewLine
$homeScreen += "  const MediGuideHomeScreen({super.key});" + [Environment]::NewLine
$homeScreen += "  @override" + [Environment]::NewLine
$homeScreen += "  State<MediGuideHomeScreen> createState() => _MediGuideHomeScreenState();" + [Environment]::NewLine
$homeScreen += "}" + [Environment]::NewLine
$homeScreen += "" + [Environment]::NewLine
$homeScreen += "class _MediGuideHomeScreenState extends State<MediGuideHomeScreen> {" + [Environment]::NewLine
$homeScreen += "  @override" + [Environment]::NewLine
$homeScreen += "  void initState() {" + [Environment]::NewLine
$homeScreen += "    super.initState();" + [Environment]::NewLine
$homeScreen += "    WidgetsBinding.instance.addPostFrameCallback((_) {" + [Environment]::NewLine
$homeScreen += "      context.read<SymptomProvider>().checkBackendHealth();" + [Environment]::NewLine
$homeScreen += "    });" + [Environment]::NewLine
$homeScreen += "  }" + [Environment]::NewLine
$homeScreen += "" + [Environment]::NewLine
$homeScreen += "  void _go(Widget screen) {" + [Environment]::NewLine
$homeScreen += "    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));" + [Environment]::NewLine
$homeScreen += "  }" + [Environment]::NewLine
$homeScreen += "" + [Environment]::NewLine
$homeScreen += "  @override" + [Environment]::NewLine
$homeScreen += "  Widget build(BuildContext context) {" + [Environment]::NewLine
$homeScreen += "    final cs = Theme.of(context).colorScheme;" + [Environment]::NewLine
$homeScreen += "    return Scaffold(" + [Environment]::NewLine
$homeScreen += "      backgroundColor: const Color(0xFFF9FAFB)," + [Environment]::NewLine
$homeScreen += "      body: SafeArea(" + [Environment]::NewLine
$homeScreen += "        child: SingleChildScrollView(" + [Environment]::NewLine
$homeScreen += "          padding: const EdgeInsets.all(20)," + [Environment]::NewLine
$homeScreen += "          child: Column(" + [Environment]::NewLine
$homeScreen += "            crossAxisAlignment: CrossAxisAlignment.start," + [Environment]::NewLine
$homeScreen += "            children: [" + [Environment]::NewLine
$homeScreen += "              Row(" + [Environment]::NewLine
$homeScreen += "                children: [" + [Environment]::NewLine
$homeScreen += "                  Icon(Icons.medical_services_rounded, color: cs.primary, size: 28)," + [Environment]::NewLine
$homeScreen += "                  const SizedBox(width: 10)," + [Environment]::NewLine
$homeScreen += "                  Text('MediGuide AI', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary))," + [Environment]::NewLine
$homeScreen += "                  const Spacer()," + [Environment]::NewLine
$homeScreen += "                  const BackendStatusIndicator()," + [Environment]::NewLine
$homeScreen += "                ]," + [Environment]::NewLine
$homeScreen += "              )," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 8)," + [Environment]::NewLine
$homeScreen += "              Text('Your AI-powered health companion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 24)," + [Environment]::NewLine
$homeScreen += "              _sectionHeader(context, Icons.biotech_rounded, 'AI Symptom Checker', const Color(0xFF2563EB))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 10)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.monitor_heart_rounded, 'Symptom Checker', 'Select symptoms via 3D anatomy or list. Get top-5 AI predictions.', const Color(0xFF2563EB), 'Geshna', () => _go(const AgeGenderScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 8)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.library_books_rounded, 'Disease Encyclopedia', 'Search 400+ diseases with AI-enhanced details.', Colors.purple, 'Geshna', () => _go(const ConditionsScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 20)," + [Environment]::NewLine
$homeScreen += "              _sectionHeader(context, Icons.medication_rounded, 'Drug Intelligence', const Color(0xFF059669))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 10)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.medication_liquid_rounded, 'Pill Identifier', 'Upload a pill photo to identify it instantly.', const Color(0xFF059669), 'Vibhu', () => _go(const PillIdentifierScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 8)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.warning_amber_rounded, 'Drug Interaction Checker', 'Check dangerous interactions between medications.', const Color(0xFFDC2626), 'Vibhu', () => _go(const DrugInteractionScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 20)," + [Environment]::NewLine
$homeScreen += "              _sectionHeader(context, Icons.local_hospital_rounded, 'Doctor Services', const Color(0xFF7C3AED))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 10)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.people_alt_rounded, 'Doctor Portal', 'Browse 500+ doctors across Tamil Nadu.', const Color(0xFF7C3AED), 'Malavika', () => _go(const DoctorPortalScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 8)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.calendar_month_rounded, 'Book Appointment', 'Schedule appointments with doctors.', const Color(0xFFEA580C), 'Malavika', () => _go(const AppointmentScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 8)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.chat_bubble_rounded, 'Medical Chatbot', 'Multilingual AI chatbot (EN/HI/TA and more).', const Color(0xFF0891B2), 'Malavika', () => _go(const ChatbotScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 8)," + [Environment]::NewLine
$homeScreen += "              _card(context, Icons.account_tree_rounded, 'Knowledge Graph', 'Explore disease-symptom relationships.', const Color(0xFF0D9488), 'Malavika', () => _go(const GraphScreen()))," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 24)," + [Environment]::NewLine
$homeScreen += "              Container(" + [Environment]::NewLine
$homeScreen += "                padding: const EdgeInsets.all(14)," + [Environment]::NewLine
$homeScreen += "                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200))," + [Environment]::NewLine
$homeScreen += "                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [" + [Environment]::NewLine
$homeScreen += "                  Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20)," + [Environment]::NewLine
$homeScreen += "                  const SizedBox(width: 10)," + [Environment]::NewLine
$homeScreen += "                  Expanded(child: Text('MediGuide AI is for informational purposes only. Always consult a qualified doctor for medical advice.', style: TextStyle(fontSize: 12, color: Colors.amber.shade900)))," + [Environment]::NewLine
$homeScreen += "                ])," + [Environment]::NewLine
$homeScreen += "              )," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 16)," + [Environment]::NewLine
$homeScreen += "            ]," + [Environment]::NewLine
$homeScreen += "          )," + [Environment]::NewLine
$homeScreen += "        )," + [Environment]::NewLine
$homeScreen += "      )," + [Environment]::NewLine
$homeScreen += "    );" + [Environment]::NewLine
$homeScreen += "  }" + [Environment]::NewLine
$homeScreen += "" + [Environment]::NewLine
$homeScreen += "  Widget _sectionHeader(BuildContext ctx, IconData icon, String label, Color color) {" + [Environment]::NewLine
$homeScreen += "    return Row(children: [" + [Environment]::NewLine
$homeScreen += "      Icon(icon, size: 15, color: color)," + [Environment]::NewLine
$homeScreen += "      const SizedBox(width: 6)," + [Environment]::NewLine
$homeScreen += "      Text(label, style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color))," + [Environment]::NewLine
$homeScreen += "      const SizedBox(width: 8)," + [Environment]::NewLine
$homeScreen += "      Expanded(child: Divider(color: color.withOpacity(0.3)))," + [Environment]::NewLine
$homeScreen += "    ]);" + [Environment]::NewLine
$homeScreen += "  }" + [Environment]::NewLine
$homeScreen += "" + [Environment]::NewLine
$homeScreen += "  Widget _card(BuildContext ctx, IconData icon, String title, String subtitle, Color color, String member, VoidCallback onTap) {" + [Environment]::NewLine
$homeScreen += "    return Card(" + [Environment]::NewLine
$homeScreen += "      child: InkWell(" + [Environment]::NewLine
$homeScreen += "        onTap: onTap," + [Environment]::NewLine
$homeScreen += "        borderRadius: BorderRadius.circular(16)," + [Environment]::NewLine
$homeScreen += "        child: Padding(" + [Environment]::NewLine
$homeScreen += "          padding: const EdgeInsets.all(14)," + [Environment]::NewLine
$homeScreen += "          child: Row(children: [" + [Environment]::NewLine
$homeScreen += "            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22))," + [Environment]::NewLine
$homeScreen += "            const SizedBox(width: 14)," + [Environment]::NewLine
$homeScreen += "            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [" + [Environment]::NewLine
$homeScreen += "              Row(children: [" + [Environment]::NewLine
$homeScreen += "                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))," + [Environment]::NewLine
$homeScreen += "                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(member, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)))," + [Environment]::NewLine
$homeScreen += "              ])," + [Environment]::NewLine
$homeScreen += "              const SizedBox(height: 3)," + [Environment]::NewLine
$homeScreen += "              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))," + [Environment]::NewLine
$homeScreen += "            ]))," + [Environment]::NewLine
$homeScreen += "            const SizedBox(width: 6)," + [Environment]::NewLine
$homeScreen += "            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey)," + [Environment]::NewLine
$homeScreen += "          ])," + [Environment]::NewLine
$homeScreen += "        )," + [Environment]::NewLine
$homeScreen += "      )," + [Environment]::NewLine
$homeScreen += "    );" + [Environment]::NewLine
$homeScreen += "  }" + [Environment]::NewLine
$homeScreen += "}" + [Environment]::NewLine

[System.IO.File]::WriteAllText("$LIB\screens\home_screen.dart", $homeScreen, [System.Text.Encoding]::UTF8)
Write-Host "  OK: lib\screens\home_screen.dart (unified)" -ForegroundColor Green

# ── VERIFY FINAL FILE LIST ────────────────────────────────────────────────────

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FILES IN lib\ RIGHT NOW              " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Get-ChildItem -Path $LIB -Recurse -Filter "*.dart" | ForEach-Object {
    Write-Host "  $($_.FullName.Replace($ROOT,''))" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   NOW RUN: flutter run -d chrome       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
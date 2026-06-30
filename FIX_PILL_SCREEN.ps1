# =============================================================================
# Fix pill_identifier_screen.dart: replace image_picker with web-compatible code
# Run from project root after FIX_SDK.ps1
# =============================================================================

$file = "X:\lib\screens\pill_identifier_screen.dart"

if (-not (Test-Path $file)) {
    $file = "D:\Desktop\6th Sem\SWE\final_flutter_integration\lib\screens\pill_identifier_screen.dart"
}

Write-Host "Patching: $file" -ForegroundColor Yellow

$c = [System.IO.File]::ReadAllText($file)
$orig = $c

# 1. Replace import
$c = $c -replace "import 'package:image_picker/image_picker\.dart';",
                 "import 'dart:typed_data';"

# 2. Replace field declaration: XFile? _pickedImage -> Uint8List? _pickedImageBytes
$c = $c -replace "XFile\? _pickedImage;", "Uint8List? _pickedImageBytes;"
$c = $c -replace "XFile\? _image;",       "Uint8List? _pickedImageBytes;"

# 3. Replace ImagePicker instance
$c = $c -replace "final _picker = ImagePicker\(\);(\r?\n)", ""
$c = $c -replace "final ImagePicker _picker = ImagePicker\(\);(\r?\n)", ""

# 4. Replace _pickImage method signature and body
$c = $c -replace `
    "Future<void> _pickImage\(ImageSource source\) async \{",
    "Future<void> _pickImage() async {"

# 5. Replace ImagePicker().pickImage() or _picker.pickImage() calls
$c = $c -replace "final XFile\? (picked|image|file) = await _picker\.pickImage\(source: ImageSource\.\w+\);",
                 "final Uint8List? bytes = await _pickImageFromWeb();"
$c = $c -replace "XFile\? (picked|image|file) = await _picker\.pickImage\(source: ImageSource\.\w+\);",
                 "final Uint8List? bytes = await _pickImageFromWeb();"

# 6. Replace null checks and file usage
$c = $c -replace "if \((picked|image|file) == null\) return;",  "if (bytes == null) return;"
$c = $c -replace "setState\(\(\) \{ _pickedImage = (picked|image|file); \}\);", `
                 "setState(() { _pickedImageBytes = bytes; });"
$c = $c -replace "_pickedImage = (picked|image|file);", "_pickedImageBytes = bytes;"
$c = $c -replace "_pickedImage!", "_pickedImageBytes!"
$c = $c -replace "_pickedImage", "_pickedImageBytes"

# 7. Replace ImageSource.gallery and ImageSource.camera calls
$c = $c -replace "_pickImage\(ImageSource\.gallery\)", "_pickImage()"
$c = $c -replace "_pickImage\(ImageSource\.camera\)",  "_pickImage()"
$c = $c -replace "ImageSource\.gallery", "null"
$c = $c -replace "ImageSource\.camera",  "null"

# 8. Add helper method before last closing brace of class if not present
if ($c -notmatch "_pickImageFromWeb") {
    $helperMethod = @'

  // Web-compatible image picker
  Future<Uint8List?> _pickImageFromWeb() async {
    try {
      // Uses dart:html file input for web
      // ignore: avoid_web_libraries_in_flutter
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();
      await input.onChange.first;
      if (input.files!.isEmpty) return null;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(input.files![0]);
      await reader.onLoad.first;
      return reader.result as Uint8List;
    } catch (e) {
      debugPrint('Image pick error: $e');
      return null;
    }
  }
'@
    # Insert before last } in the file
    $lastBrace = $c.LastIndexOf('}')
    if ($lastBrace -ge 0) {
        $c = $c.Substring(0, $lastBrace) + $helperMethod + $c.Substring($lastBrace)
    }

    # Add html import at top
    $c = "import 'dart:html' as html;`n" + $c
}

# 9. Fix Image display: replace File(_pickedImage.path) with Image.memory(_pickedImageBytes)
$c = $c -replace "Image\.file\(File\(_pickedImageBytes\.path\)\)",  "Image.memory(_pickedImageBytes!)"
$c = $c -replace "Image\.file\(File\(_pickedImage!\.path\)\)",      "Image.memory(_pickedImageBytes!)"
$c = $c -replace "Image\.file\(File\([^)]+\.path\)\)",             "Image.memory(_pickedImageBytes!)"

# 10. Remove any remaining File() import or usage since we use bytes
$c = $c -replace "import 'dart:io';(\r?\n)", ""

if ($c -ne $orig) {
    [System.IO.File]::WriteAllText($file, $c, [System.Text.Encoding]::UTF8)
    Write-Host "  OK: pill_identifier_screen.dart patched" -ForegroundColor Green
} else {
    Write-Host "  No changes made - may need manual fix" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Now check for any remaining 'ImagePicker' or 'XFile' references:" -ForegroundColor Cyan
Select-String -Path $file -Pattern "ImagePicker|XFile|ImageSource|image_picker" | ForEach-Object {
    Write-Host "  Line $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor Red
}
Write-Host "Done" -ForegroundColor Green
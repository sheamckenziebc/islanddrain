# This script refactors the asset structure to be clean and simple for a static site.

$ErrorActionPreference = 'Stop'
Write-Host "--- Starting Asset Refactor Script ---"

# Define paths
$docsDir = "./docs"
$newStylesDir = "$docsDir/styles"
$newScriptsDir = "$docsDir/scripts"
$newFontsDir = "$docsDir/fonts"

# Use an explicit list of files to avoid discovery issues
$htmlFiles = @(
    "$docsDir/index.html",
    "$docsDir/about.html",
    "$docsDir/contact.html",
    "$docsDir/services.html"
)
Write-Host "Found $($htmlFiles.Count) HTML files to process."

# --- 1. Create new asset directories ---
Write-Host "Creating new asset directories..."
if (-not (Test-Path $newStylesDir)) { New-Item -ItemType Directory -Path $newStylesDir }
if (-not (Test-Path $newScriptsDir)) { New-Item -ItemType Directory -Path $newScriptsDir }
if (-not (Test-Path $newFontsDir)) { New-Item -ItemType Directory -Path $newFontsDir }
Write-Host "Directories created successfully."

$copiedFiles = @{}

# --- 2. Process each HTML file ---
foreach ($file in $htmlFiles) {
    if (-not(Test-Path $file)) {
        Write-Warning "File not found: $file. Skipping."
        continue
    }

    Write-Host "Processing $($file)..."
    $content = Get-Content $file -Raw

    # --- 3. Find, copy, and relink all CSS files ---
    $cssMatches = [regex]::Matches($content, '(?i)<link.*?rel="stylesheet".*?href="([^"]+)"')
    Write-Host "  Found $($cssMatches.Count) CSS links."
    foreach ($match in $cssMatches) {
        $oldHref = $match.Groups[1].Value
        if ($oldHref.StartsWith("http")) { 
            Write-Host "    Skipping external CSS: $oldHref"
            continue 
        }

        $fileName = [System.IO.Path]::GetFileName($oldHref.Split('?')[0])
        $sourcePath = Join-Path -Path $docsDir -ChildPath $oldHref.TrimStart('/')
        $destPath = Join-Path -Path $newStylesDir -ChildPath $fileName
        $newHref = "/styles/$fileName"

        if ((Test-Path $sourcePath) -and (-not $copiedFiles.ContainsKey($destPath))) {
            Write-Host "    Copying CSS: $fileName"
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            $copiedFiles[$destPath] = $true
        }
        
        $content = $content.Replace($oldHref, $newHref)
    }

    # --- 4. Find, copy, and relink all JS files ---
    $jsMatches = [regex]::Matches($content, '(?i)<script.*?src="([^"]+)"')
    Write-Host "  Found $($jsMatches.Count) JS links."
    foreach ($match in $jsMatches) {
        $oldSrc = $match.Groups[1].Value
        if ($oldSrc.StartsWith("http")) { 
             Write-Host "    Skipping external JS: $oldSrc"
            continue 
        }

        $fileName = [System.IO.Path]::GetFileName($oldSrc.Split('?')[0])
        $sourcePath = Join-Path -Path $docsDir -ChildPath $oldSrc.TrimStart('/')
        $destPath = Join-Path -Path $newScriptsDir -ChildPath $fileName
        $newSrc = "/scripts/$fileName"
        
        if ((Test-Path $sourcePath) -and (-not $copiedFiles.ContainsKey($destPath))) {
            Write-Host "    Copying JS: $fileName"
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            $copiedFiles[$destPath] = $true
        }

        $content = $content.Replace($oldSrc, $newSrc)
    }

    # Save the updated HTML content
    Set-Content -Path $file -Value $content -Force
    Write-Host "  Finished processing $file."
}

# --- 5. Find and copy font files ---
Write-Host "Copying required font files..."
$fontAwesomeCssDir = "$docsDir/assets/wp-content/plugins/elementor/assets/lib/font-awesome"
if (Test-Path "$fontAwesomeCssDir/fonts") {
    Copy-Item -Path "$fontAwesomeCssDir/fonts/*" -Destination $newFontsDir -Recurse -Force
}
$blogDesignerCssDir = "$docsDir/assets/wp-content/plugins/blog-designer/admin"
if (Test-Path "$blogDesignerCssDir/fonts") {
    Copy-Item -Path "$blogDesignerCssDir/fonts/*" -Destination $newFontsDir -Recurse -Force
}
$oceanWpCssDir = "$docsDir/assets/wp-content/themes/oceanwp/assets/fonts/simple-line-icons"
if (Test-Path $oceanWpCssDir) {
    Copy-Item -Path "$oceanWpCssDir/*" -Destination $newFontsDir -Recurse -Force
}
Write-Host "Font copying complete."

# --- 6. Update font paths within the new CSS files ---
Write-Host "Updating font paths in stylesheets..."
$cssFilesToUpdate = Get-ChildItem -Path $newStylesDir -Filter "*.css"
foreach ($cssFile in $cssFilesToUpdate) {
    $cssContent = Get-Content $cssFile.FullName -Raw
    $updatedCssContent = $cssContent -replace '\.\./fonts/', '/fonts/'
    $updatedCssContent = $updatedCssContent -replace '\.\./webfonts/', '/fonts/'
    Set-Content -Path $cssFile.FullName -Value $updatedCssContent -Force
}

Write-Host "--- Asset Refactoring Complete. The structure is now clean. ---" 
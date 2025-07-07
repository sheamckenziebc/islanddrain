# This script restores the site to a clean state.

$docsDir = "./docs"
$originalDir = "./simply-static-1-1751814525"

# --- 1. Restore index.html ---
Copy-Item -Path "$originalDir/index.html" -Destination "$docsDir/index.html" -Force
Write-Host "Restored index.html"

# --- 2. Create blank placeholder pages ---
$pageTemplate = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{0}</title>
    <link rel="stylesheet" id="oceanwp-style-css" href="/assets/wp-content/themes/oceanwp/assets/css/style.min.css" type="text/css" media="all">
    <link rel="stylesheet" id="elementor-frontend-css" href="/assets/wp-content/plugins/elementor/assets/css/frontend.min.css" type="text/css" media="all">
</head>
<body>
    <header id="site-header" class="minimal-header-style">
        <div id="site-header-inner" class="clr">
            <div id="site-navigation-wrap" class="clr">
                <nav id="site-navigation" class="navigation main-navigation clr" role="navigation">
                    <ul id="menu-main-menu" class="main-menu">
                        <li><a href="/index.html">Home</a></li>
                        <li><a href="/services.html">Services</a></li>
                        <li><a href="/about.html">About</a></li>
                        <li><a href="/contact.html">Contact</a></li>
                    </ul>
                </nav>
            </div>
        </div>
    </header>
    <main>
        <!-- Page content will be injected here -->
    </main>
</body>
</html>
"@

# Create About page
$aboutTitle = "About Us - Island Drains and Excavation"
$aboutContent = [string]::Format($pageTemplate, $aboutTitle)
Set-Content -Path "$docsDir/about.html" -Value $aboutContent -Force
Write-Host "Created blank about.html"

# Create Contact page
$contactTitle = "Contact Us - Island Drains and Excavation"
$contactContent = [string]::Format($pageTemplate, $contactTitle)
Set-Content -Path "$docsDir/contact.html" -Value $contactContent -Force
Write-Host "Created blank contact.html"

# Create Services page
$servicesTitle = "Our Services - Island Drains and Excavation"
$servicesContent = [string]::Format($pageTemplate, $servicesTitle)
Set-Content -Path "$docsDir/services.html" -Value $servicesContent -Force
Write-Host "Created blank services.html"


# --- 3. Clean all HTML files ---
$htmlFiles = Get-ChildItem -Path $docsDir -Filter "*.html" -Recurse
# This is the specific, problematic script line from 10Web Booster
$badScriptPattern = '<!-- <script data-pagespeed-no-defer data-two-no-delay type="text/javascript">var two_worker_data.*?</script> -->'

foreach ($file in $htmlFiles) {
    Write-Host "Cleaning $($file.FullName)..."
    $content = Get-Content $file.FullName -Raw
    
    # Use a simple, non-greedy regex to remove the script tag and its contents
    $cleanedContent = $content -replace '(?s)<!-- <script data-pagespeed-no-defer.*?<\/script> -->', ''
    
    Set-Content -Path $file.FullName -Value $cleanedContent -Force
}

Write-Host "Cleanup complete." 
# This script fixes the styling by injecting the correct CSS links into all HTML files.

$htmlFiles = Get-ChildItem -Path "./docs" -Filter "*.html" -Recurse

# Define the CSS links to be added. These paths are relative to the docs root.
$newCssLinks = @"
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css?family=Montserrat%3A100%2C200%2C300%2C400%2C500%2C600%2C700%2C800%2C900&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Marcellus+SC&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Roboto%3A100%2C100italic%2C300%2C400%2C500%2C700%7CRoboto+Slab%3A100%2C300%2C400%2C700&display=swap" rel="stylesheet">

    <!-- Main Stylesheets (from docs/assets) -->
    <link rel="stylesheet" href="/assets/wp-content/themes/oceanwp/assets/css/style.min.css" type="text/css" media="all">
    <link rel="stylesheet" href="/assets/wp-content/plugins/elementor/assets/css/frontend.min.css" type="text/css" media="all">
    <link rel="stylesheet" href="/assets/wp-content/plugins/elementor/assets/lib/font-awesome/css/font-awesome.min.css" type="text/css" media="all">
    <link rel="stylesheet" href="/assets/wp-content/uploads/elementor/css/custom-frontend.min.css" type="text/css" media="all">
    <link rel="stylesheet" href="/assets/wp-content/plugins/ocean-extra/assets/css/widgets.css" type="text/css" media="all">
    <link rel="stylesheet" href="/assets/wp-content/plugins/ocean-social-sharing/assets/css/style.min.css" type="text/css" media="all">
    <link rel="stylesheet" href="/assets/wp-content/plugins/blog-designer/admin/css/fontawesome-all.min.css" type="text/css" media="all">

    <!-- Favicon -->
    <link rel="icon" href="/assets/wp-content/uploads/2023/05/cropped-unnamed-4-removebg-preview-1-32x32.png" sizes="32x32">
"@

foreach ($file in $htmlFiles) {
    Write-Host "Processing $($file.FullName)..."
    $content = Get-Content $file.FullName -Raw

    # Extract existing title to preserve it
    $titleMatch = [regex]::Match($content, '(?s)<title>(.*?)</title>')
    $title = if ($titleMatch.Success) { $titleMatch.Value } else { "<title>Island Drains and Excavation</title>" }

    # Define the full new head
    $newHead = @"
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    $title
$newCssLinks
</head>
"@

    # Replace the old head with the new one
    $cleanedContent = $content -replace '(?s)<head>.*?</head>', $newHead

    # Save the updated content
    Set-Content -Path $file.FullName -Value $cleanedContent -Force
}

Write-Host "Finished updating styles for all HTML files." 
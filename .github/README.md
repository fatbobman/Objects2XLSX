# GitHub Actions Configuration

This directory contains GitHub Actions workflows for the Objects2XLSX project.

## Documentation Workflow

The `documentation.yml` workflow automatically builds and deploys Swift DocC documentation to GitHub Pages.

### Setup Instructions

To enable automatic documentation deployment:

1. **Enable GitHub Pages in your repository:**
   - Go to your repository Settings
   - Navigate to "Pages" in the left sidebar
   - Under "Source", select "GitHub Actions"
   - Save the settings

2. **Configure repository permissions:**
   - The workflow requires `pages: write` and `id-token: write` permissions
   - These are already configured in the workflow file

3. **Trigger the workflow:**
   - The workflow runs automatically on pushes to `main` branch
   - You can also trigger it manually from the Actions tab
   - It only runs when documentation-related files change

### Workflow Features

- **Smart triggering**: Only runs when relevant files change
- **Dual build methods**: Tries modern `swift package` command first, falls back to `xcodebuild`
- **Caching**: Uses SPM caching for faster builds
- **Verification**: Checks that documentation was successfully generated
- **Static hosting**: Optimizes documentation for GitHub Pages

### Accessing Documentation

Once deployed, your documentation will be available at:
```
https://[username].github.io/Objects2XLSX/
```

### Troubleshooting

If the workflow fails:

1. **Check the Actions logs** for detailed error messages
2. **Verify DocC syntax** by building documentation locally:
   ```bash
   swift package generate-documentation --target Objects2XLSX
   ```
3. **Ensure GitHub Pages is enabled** in repository settings
4. **Check repository permissions** for the Actions

### Local Documentation Building

To build documentation locally for testing:

```bash
# Method 1: Using swift package (preferred)
swift package generate-documentation --target Objects2XLSX

# Method 2: Using xcodebuild
xcodebuild docbuild -scheme Objects2XLSX -destination generic/platform=macOS
```

The generated documentation will be in `.build/plugins/Swift-DocC/outputs/Objects2XLSX.doccarchive`.
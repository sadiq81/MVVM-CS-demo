#!/bin/bash
set -euo pipefail

# ============================================================================
# Snapshot Comparison Script
# Runs snapshot tests for all 3 app targets, extracts images from xcresult
# bundles, and organizes them for side-by-side comparison.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${PROJECT_DIR}/SnapshotComparison"
DERIVED_DATA="${PROJECT_DIR}/.build/snapshot-derived-data"
DESTINATION="${SNAPSHOT_DESTINATION:-platform=iOS Simulator,name=iPhone 16,OS=latest}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Snapshot Comparison Tool ===${NC}"
echo "Output directory: ${OUTPUT_DIR}"
echo ""

# Clean previous results
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}/UIKit" "${OUTPUT_DIR}/Mixed" "${OUTPUT_DIR}/SwiftUI" "${OUTPUT_DIR}/report"

# ============================================================================
# Step 1: Run snapshot tests for each target
# ============================================================================

run_snapshots() {
    local scheme="$1"
    local test_target="$2"
    local label="$3"
    local result_path="${OUTPUT_DIR}/${label}.xcresult"

    echo -e "${YELLOW}Running ${label} snapshots...${NC}"

    xcodebuild test \
        -project "${PROJECT_DIR}/customerapp.xcodeproj" \
        -scheme "${scheme}" \
        -only-testing "${test_target}" \
        -destination "${DESTINATION}" \
        -derivedDataPath "${DERIVED_DATA}" \
        -resultBundlePath "${result_path}" \
        -quiet \
        2>&1 | grep -E "Test Suite|Test Case|passed|failed" || true

    if [ -d "${result_path}" ]; then
        echo -e "${GREEN}  ✓ ${label} snapshots generated${NC}"
    else
        echo -e "${RED}  ✗ ${label} snapshots failed${NC}"
    fi
}

run_snapshots "UIKit-Development" "UIKit-SnapshotTests" "UIKit"
run_snapshots "Mixed-Development" "Mixed-SnapshotTests" "Mixed"
run_snapshots "SwiftUI-Development" "SwiftUI-SnapshotTests" "SwiftUI"

# ============================================================================
# Step 2: Extract snapshot attachments from xcresult bundles
# ============================================================================

extract_snapshots() {
    local label="$1"
    local result_path="${OUTPUT_DIR}/${label}.xcresult"
    local output_path="${OUTPUT_DIR}/${label}"

    if [ ! -d "${result_path}" ]; then
        echo -e "${RED}No xcresult found for ${label}${NC}"
        return
    fi

    echo -e "${YELLOW}Extracting ${label} snapshots...${NC}"

    # Get test reference IDs from the xcresult
    xcresulttool get --path "${result_path}" --format json 2>/dev/null | \
        python3 -c "
import json, sys, subprocess, os

data = json.load(sys.stdin)
output_path = '${output_path}'

def find_attachments(obj, path=''):
    if isinstance(obj, dict):
        # Look for attachment nodes with snapshot images
        if obj.get('_type', {}).get('_name') == 'ActionTestAttachment':
            name = obj.get('name', {}).get('_value', 'unknown')
            payload_ref = obj.get('payloadRef', {}).get('id', {}).get('_value')
            if payload_ref and name.endswith('.png'):
                # Clean up the name for filesystem
                clean_name = name.replace(' ', '_').replace('/', '_')
                output_file = os.path.join(output_path, clean_name)
                try:
                    result = subprocess.run(
                        ['xcresulttool', 'get', '--path', '${result_path}', '--id', payload_ref],
                        capture_output=True
                    )
                    if result.returncode == 0:
                        with open(output_file, 'wb') as f:
                            f.write(result.stdout)
                        print(f'  Extracted: {clean_name}')
                except Exception as e:
                    print(f'  Error: {e}', file=sys.stderr)

        for key, value in obj.items():
            find_attachments(value, f'{path}.{key}')
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            find_attachments(item, f'{path}[{i}]')

find_attachments(data)
" 2>/dev/null || echo "  (extraction requires xcresulttool)"

    local count=$(find "${output_path}" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${GREEN}  ✓ Extracted ${count} snapshots for ${label}${NC}"
}

extract_snapshots "UIKit"
extract_snapshots "Mixed"
extract_snapshots "SwiftUI"

# ============================================================================
# Step 3: Generate HTML comparison report
# ============================================================================

echo -e "${YELLOW}Generating comparison report...${NC}"

cat > "${OUTPUT_DIR}/report/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Snapshot Comparison Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #f5f5f5; padding: 20px; }
        h1 { text-align: center; margin-bottom: 20px; color: #333; }
        .comparison { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 32px; }
        .comparison h2 { grid-column: 1 / -1; font-size: 18px; color: #666; border-bottom: 1px solid #ddd; padding-bottom: 8px; }
        .snapshot { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .snapshot img { width: 100%; height: auto; display: block; }
        .snapshot .label { padding: 8px 12px; font-size: 12px; font-weight: 600; color: #888; text-transform: uppercase; }
        .missing { display: flex; align-items: center; justify-content: center; min-height: 200px; color: #ccc; font-style: italic; }
    </style>
</head>
<body>
    <h1>Snapshot Comparison — UIKit vs Mixed vs SwiftUI</h1>
    <div id="comparisons"></div>
    <script>
        // This would be populated by the script below
        document.getElementById('comparisons').innerHTML = '<p style="text-align:center;color:#999;">Run the comparison script to populate this report.</p>';
    </script>
</body>
</html>
HTMLEOF

# Populate the report with actual snapshots
python3 -c "
import os, glob

output_dir = '${OUTPUT_DIR}'
apps = ['UIKit', 'Mixed', 'SwiftUI']

# Collect all unique snapshot names across apps
all_names = set()
for app in apps:
    app_dir = os.path.join(output_dir, app)
    if os.path.exists(app_dir):
        for f in glob.glob(os.path.join(app_dir, '*.png')):
            all_names.add(os.path.basename(f))

if not all_names:
    print('No snapshots found to compare.')
    exit(0)

# Generate HTML
html = '''<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <title>Snapshot Comparison Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #f5f5f5; padding: 20px; }
        h1 { text-align: center; margin-bottom: 20px; color: #333; }
        .comparison { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 32px; }
        .comparison h2 { grid-column: 1 / -1; font-size: 18px; color: #666; border-bottom: 1px solid #ddd; padding-bottom: 8px; }
        .snapshot { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .snapshot img { width: 100%; height: auto; display: block; }
        .snapshot .label { padding: 8px 12px; font-size: 12px; font-weight: 600; color: #888; text-transform: uppercase; }
        .missing { background: white; border-radius: 8px; display: flex; align-items: center; justify-content: center; min-height: 200px; color: #ccc; font-style: italic; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <h1>Snapshot Comparison — UIKit vs Mixed vs SwiftUI</h1>
'''

for name in sorted(all_names):
    display_name = name.replace('.png', '').replace('_', ' ')
    html += f'<div class=\"comparison\"><h2>{display_name}</h2>'
    for app in apps:
        img_path = os.path.join('..', app, name)
        full_path = os.path.join(output_dir, app, name)
        if os.path.exists(full_path):
            html += f'<div class=\"snapshot\"><div class=\"label\">{app}</div><img src=\"{img_path}\" alt=\"{app} - {display_name}\"></div>'
        else:
            html += f'<div class=\"missing\">{app}: not found</div>'
    html += '</div>'

html += '</body></html>'

report_path = os.path.join(output_dir, 'report', 'index.html')
with open(report_path, 'w') as f:
    f.write(html)

print(f'Report generated with {len(all_names)} comparisons')
" 2>/dev/null || echo "Report generation requires python3"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${GREEN}=== Done ===${NC}"
echo "Snapshots: ${OUTPUT_DIR}/"
echo "  UIKit/:   $(find "${OUTPUT_DIR}/UIKit" -name "*.png" 2>/dev/null | wc -l | tr -d ' ') images"
echo "  Mixed/:   $(find "${OUTPUT_DIR}/Mixed" -name "*.png" 2>/dev/null | wc -l | tr -d ' ') images"
echo "  SwiftUI/: $(find "${OUTPUT_DIR}/SwiftUI" -name "*.png" 2>/dev/null | wc -l | tr -d ' ') images"
echo "Report:   ${OUTPUT_DIR}/report/index.html"
echo ""
echo "Open the report:"
echo "  open ${OUTPUT_DIR}/report/index.html"

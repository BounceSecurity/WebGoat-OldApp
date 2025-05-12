#!/bin/bash

# Note that this used Semgrep 1.85.0

# Check if semgrep_results directory exists, create if not
if [ ! -d "semgrep_results" ]; then
    mkdir semgrep_results
fi

# Note that this does not run pro rules to avoid having to do semgrep login
# First, check if semgrep is installed
if ! command -v semgrep &> /dev/null; then
    echo "Semgrep is not installed. Please install it using 'pip install semgrep'"
    exit 1
fi

# Check if aha is installed (for HTML conversion)
if ! command -v aha &> /dev/null; then
    echo "Warning: 'aha' is not installed. HTML output will not be generated."
    echo "You can install this with 'sudo apt install aha'"
    HAS_AHA=false
else
    HAS_AHA=true
fi

# Run semgrep with different output formats

echo "Running semgrep with regular rules..."

semgrep --oss-only --config p/java --config r/contrib.owasp.java --metrics=off --severity=WARNING --severity=ERROR \
--exclude-rule java.spring.security.injection.tainted-url-host.tainted-url-host \
--exclude-rule java.lang.security.httpservlet-path-traversal.httpservlet-path-traversal \
--force-color  --no-git-ignore --text-output=semgrep_results/semgrep_results_reg.txt --sarif-output=semgrep_results/semgrep_results_reg.sarif

cd semgrep_results/

# Convert to HTML if aha is available
if [ "$HAS_AHA" = true ]; then
  echo "Converting results to HTML..."
  cat semgrep_results_reg.txt | aha --black > semgrep_results_reg.html
else
  echo "Skipping HTML conversion (aha not installed)"
fi

# Update SARIF files
echo "Updating SARIF files..."
if command -v sed &> /dev/null; then
  sed -i 's/"name": "semgrep",/"name": "semgrep-regular",/' semgrep_results_reg.sarif
else
  echo "Warning: 'sed' command not found. SARIF files not updated."
fi

echo "Semgrep scan completed. Results are in the semgrep_results directory."
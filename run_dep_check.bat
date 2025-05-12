REM Pass the NVD API key as a parameter
mvn org.owasp:dependency-check-maven:check -DnvdApiKey=%1 -DassemblyAnalyzerEnabled=false "-Dformats=XML,HTML"

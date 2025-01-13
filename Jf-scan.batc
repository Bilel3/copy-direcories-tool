@echo off
:: Set the output file name
set OUTPUT_FILE=scan_results.txt

:: Clear the output file if it exists
echo Scanning JAR files for vulnerabilities... > "%OUTPUT_FILE%"

:: Loop through each JAR file in the current directory
for %%f in (*.jar) do (
    echo Scanning %%f... >> "%OUTPUT_FILE%"
    echo ================================================== >> "%OUTPUT_FILE%"
    jf scan "%%f" --format table >> "%OUTPUT_FILE%"
    echo ================================================== >> "%OUTPUT_FILE%"
    echo. >> "%OUTPUT_FILE%" 
)

:: Display a success message
echo All JAR files scanned. Results saved to %OUTPUT_FILE%.
pause

@echo off
REM NJU Thesis Quick Compile Script
REM Usage: Double-click to run

echo ====================================
echo    NJU Thesis Quick Compile
echo ====================================
echo.

REM Quick compile (without bibliography)
echo [1/1] Compiling...
xelatex -interaction=nonstopmode njuthesis-thesis.tex

echo.
echo ====================================
echo    Compile Complete!
echo ====================================
echo.
echo Output: njuthesis-thesis.pdf
echo.
echo For full compile with bibliography, run: compile-full.bat
echo.

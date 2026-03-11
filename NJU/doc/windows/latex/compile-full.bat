@echo off
REM NJU Thesis Full Compile Script (with bibliography)
REM Usage: Double-click to run

echo ====================================
echo    NJU Thesis Full Compile
echo    (with bibliography)
echo ====================================
echo.

echo [1/4] First compile...
xelatex -interaction=nonstopmode njuthesis-thesis.tex
echo.

echo [2/4] Generating bibliography...
biber njuthesis-thesis
echo.

echo [3/4] Second compile...
xelatex -interaction=nonstopmode njuthesis-thesis.tex
echo.

echo [4/4] Third compile...
xelatex -interaction=nonstopmode njuthesis-thesis.tex

echo.
echo ====================================
echo    Full Compile Complete!
echo ====================================
echo.
echo Output: njuthesis-thesis.pdf
echo.

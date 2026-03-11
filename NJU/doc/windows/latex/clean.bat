@echo off
REM LaTeX auxiliary files cleanup script
REM Usage: Double-click to run

echo ====================================
echo    Cleaning auxiliary files...
echo ====================================
echo.

del /Q *.aux 2>nul
del /Q *.bbl 2>nul
del /Q *.blg 2>nul
del /Q *.idx 2>nul
del /Q *.ind 2>nul
del /Q *.lof 2>nul
del /Q *.lot 2>nul
del /Q *.out 2>nul
del /Q *.toc 2>nul
del /Q *.acn 2>nul
del /Q *.acr 2>nul
del /Q *.alg 2>nul
del /Q *.glg 2>nul
del /Q *.glo 2>nul
del /Q *.gls 2>nul
del /Q *.ist 2>nul
del /Q *.fls 2>nul
del /Q *.log 2>nul
del /Q *.fdb_latexmk 2>nul
del /Q *.synctex.gz 2>nul
del /Q *.run.xml 2>nul
del /Q *.bcf 2>nul
del /Q *.thm 2>nul

echo.
echo ====================================
echo    Cleanup complete!
echo ====================================
echo.
echo Note: PDF files are kept
echo.
pause

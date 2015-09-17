@echo off
if exist "C:\Program Files(x86)\SuperCollider*\sclang.exe" (
	"C:\Program Files(x86)\SuperCollider*\sclang.exe" "C:\Users\%USERNAME%\AppData\Local\SuperCollider\menagerie_run.scd"
) else (
	"C:\Program Files\SuperCollider*\sclang.exe" "C:\Users\%USERNAME%\AppData\Local\SuperCollider\menagerie_run.scd"
)
echo "Press any button to continue..."
PAUSE 1> nul
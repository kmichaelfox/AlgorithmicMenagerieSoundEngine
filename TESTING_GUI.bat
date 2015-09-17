@echo off
if exist "C:\Program Files (x86)\SuperCollider*" (
	cd "C:\Program Files (x86)\SuperCollider*"
	"sclang.exe" "C:\Users\%USERNAME%\AppData\Local\SuperCollider\menagerie_gui.scd"
) else (
	cd "C:\Program Files\SuperCollider*"
	"sclang.exe" "C:\Users\%USERNAME%\AppData\Local\SuperCollider\menagerie_gui.scd"
)
echo "Press any button to continue..."
PAUSE 1> nul
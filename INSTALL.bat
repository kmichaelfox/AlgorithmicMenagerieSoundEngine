@echo off
set _=%CD%

robocopy "%_%\SCMenagerieLibrary" "C:\Users\%USERNAME%\AppData\Local\SuperCollider\Extensions\SCMenagerieLibrary" /s /e
copy "%_%\exhibition_startup.scd" "C:\Users\%USERNAME%\AppData\Local\SuperCollider"

echo "Press any button to continue..."
PAUSE 1> nul
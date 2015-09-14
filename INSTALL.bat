@echo off
set _=%CD%

robocopy "%_%\SCMenagerieLibrary" "C:\Users\%USERNAME%\AppData\Local\SuperCollider\Extensions\SCMenagerieLibrary" /s /e

echo "Press any button to continue..."
PAUSE 1> nul
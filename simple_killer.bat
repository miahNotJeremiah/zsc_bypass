@echo off
:loop
//search for Task in Windows Task Manager
for /f "tokens=1" %%i in ('tasklist ^| findstr "ZSA"') do (
    TASKKILL /F /IM %%i /T
print("task killed")
)
goto loop

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                              ::
::  How to use...                                               ::
::  Edit row 24 & 25 where is the "WinTer_Org_Location"         ::
::  and "WinTer_Back_Location" insert own directories           ::
::  Run "Task Scheduler" (integrated windows app by Microsoft)  ::
::  and "Create Task" in tab "General" select Radio to          ::
::  "Run whether user is logged on or not" check                ::
::  "Do not store password. ..." and check                      ::
::  "Run with highest privileges".                              ::
::                                                              :: 
::  __________________________________________________________  ::
::                                                              ::
::  You can also save this script in the folder                 ::
::  where you synchronize the backup.                           ::
::                                                              ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



@echo off

:: SET two file source and backup destination (OneDrive, Drive by Google, DropBox, Syncthing, Resilio Sync...)
SET WinTer_Org_Location=C:\Users\%username%\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json
SET WinTer_Back_Location=C:\Users\%username%\Sync\SyncData\0\WindowsTerminal\settings.json
:: If file not exist in backup destination copy file from original location
If NOT EXIST "%WinTer_Back_Location%" (copy %WinTer_Org_Location% %WinTer_Back_Location% /Y)


:: Infinite loop with HASH and Timestrap comparating.
:LOOP
:: Getting Hash and Timestrap
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell -executionpolicy remotesigned -Command "Get-FileHash %WinTer_Org_Location% | Select-Object Hash | Format-Table -HideTableHeaders"`) DO (
    SET ORG_HASH=%%F
)
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell -executionpolicy remotesigned -Command "Get-FileHash %WinTer_Back_Location% | Select-Object Hash | Format-Table -HideTableHeaders"`) DO (
    SET BACK_HASH=%%F
)

FOR /F "usebackq delims=" %%I in (`powershell -executionpolicy remotesigned -Command "get-childitem -Path %WinTer_Org_Location% | Select-Object LastWriteTime | Format-Table -HideTableHeaders"`) DO (
    SET "ORG_DATE=%%I"
)
FOR /F "usebackq delims=" %%I in (`powershell -executionpolicy remotesigned -Command "get-childitem -Path %WinTer_Back_Location% | Select-Object LastWriteTime | Format-Table -HideTableHeaders"`) DO (
    SET "BACK_DATE=%%I"
)

::Conditions If files is same or differently
IF "%ORG_HASH%" == "%BACK_HASH%" GOTO LOOP
IF NOT "%ORG_HASH%" == "%BACK_HASH%" GOTO GETDATE


:: Use simple xcopy comand between original and backup file
:GETDATE

IF "%ORG_DATE%" GTR "%BACK_DATE%" (xcopy %WinTer_Org_Location% %WinTer_Back_Location% /Y)
IF "%BACK_DATE%" GTR "%ORG_DATE%" (xcopy %WinTer_Back_Location% %WinTer_Org_Location% /Y)


:: Back to up.
GOTO LOOP
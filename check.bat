@echo off
setlocal
setlocal EnableDelayedExpansion
color 09
chcp 65001 > nul
set "1= "
title Nebula Solutions HWID Checker
echo.
echo  ██╗░░██╗░██╗░░░░░░░██╗██╗██████╗░  ░█████╗░██╗░░██╗███████╗░█████╗░██╗░░██╗███████╗██████╗░
echo  ██║░░██║░██║░░██╗░░██║██║██╔══██╗  ██╔══██╗██║░░██║██╔════╝██╔══██╗██║░██╔╝██╔════╝██╔══██╗
echo  ███████║░╚██╗████╗██╔╝██║██║░░██║  ██║░░╚═╝███████║█████╗░░██║░░╚═╝█████═╝░█████╗░░██████╔╝
echo  ██╔══██║░░████╔═████║░██║██║░░██║  ██║░░██╗██╔══██║██╔══╝░░██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
echo  ██║░░██║░░╚██╔╝░╚██╔╝░██║██████╔╝  ╚█████╔╝██║░░██║███████╗╚█████╔╝██║░╚██╗███████╗██║░░██║
echo  ╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░  ░╚════╝░╚═╝░░╚═╝╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
echo.
set /p WEBHOOK_URL=Enter Webhook URL: 
cls
chcp 437 > nul
echo Retriving Serials
echo.
for /f "tokens=2 delims==" %%i in ('wmic csproduct get uuid /value ^| find "="') do set uuid=%%i
for /f "tokens=2 delims==" %%j in ('wmic bios get serialnumber /value ^| find "="') do set bios=%%j
for /f "tokens=2 delims==" %%j in ('wmic systemenclosure get serialnumber /value ^| find "="') do set chassis=%%j
for /f "tokens=2 delims==" %%j in ('wmic baseboard get serialnumber /value ^| find "="') do set baseboard=%%j
for /f "skip=1 delims=" %%a in ('wmic nicconfig where "IPEnabled=true" get MACAddress^,IPAddress /format:list ^| findstr /r /v "^$"') do (
    set "line=%%a"
    if "!line:~0,11!"=="MACAddress=" (
        set "mac=!line:~11!"
        goto :exit_loop
    )
)
:exit_loop
for /f "tokens=2 delims==" %%j in ('wmic cpu get SerialNumber /value ^| find "="') do set cpu=%%j
echo Serials Retrived
echo.
set "JSON_PAYLOAD={\"embeds\": [{\"title\": \"Nebula Solutions HWID Checker\", \"color\": 13085430, \"description\": \"**UUID:** \n ```%uuid%``` \n **BIOS Serial Number:** \n ```%bios%``` \n **Chassis Serial Number:** \n ```%chassis%``` \n **Baseboard Serial Number:** \n ```%baseboard%```  \n **CPU Serial Number:** \n ```%cpu%``` \n **Mac Address:** \n ```%mac%```\"}]}"
echo Sending to Webhook
powershell -Command "Invoke-RestMethod -Uri '%WEBHOOK_URL%' -Method Post -ContentType 'application/json' -Body '%JSON_PAYLOAD%'"
echo Serials Sent to Webhook
echo.
pause
exit
endlocal
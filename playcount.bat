@echo off
title Play Corrector
color a
setlocal enableextensions
setlocal enabledelayedexpansion

:Start
set /a totalSongs=0
set /a count=1
set /a down=0
set /a slowmode=1
set /a checkin=0
set /a currentPlays=0
echo How many songs are there on this playlist?
set /p totalSongs=
if %totalSongs%==0 goto Start
pause
nircmd.exe clipboard clear
echo Starting...
del log.txt
timeout 1 /nobreak


:Loop
echo. > output.txt
timeout 0 /nobreak

:: Grab song name

:: Clicks another song to prevent lossing blue highlight
nircmd.exe setcursor -850 200
nircmd.exe sendmouse left click
timeout 0 /nobreak  >nul

:: First song of list
set /a y=110+%down%
nircmd.exe setcursor -850 %y%
nircmd.exe sendmouse left click
nircmd.exe wait 20
nircmd.exe sendkeypress ctrl+c
timeout 0 /nobreak >nul
nircmd.exe clipboard writefile data.txt
timeout 0 /nobreak >nul
set /p songName=<data.txt
nircmd.exe wait 30
echo Song name: %songName% >> log.txt

:: Makes sure that there's no spaces in name
call :Trim songName %songName%
nircmd.exe clipboard set "<key>Name</key><string>%songName%</string>"
nircmd.exe wait 15
if %slowmode% GTR 0  timeout %slowmode% >nul
echo Trimmed >> log.txt

:: Search song name

:: Click on code
nircmd.exe setcursor -1500 500
nircmd.exe sendmouse left click
:: Click on search Bar
nircmd.exe setcursor -1400 80
nircmd.exe sendmouse left click
nircmd.exe wait 15
if %slowmode% GTR 0  timeout %slowmode% >nul

:: Searches for name
nircmd.exe sendkeypress ctrl+v
nircmd.exe sendkey enter press

nircmd.exe clipboard clear
nircmd.exe wait 15
if %slowmode% GTR 0  timeout %slowmode% >nul

:: Copies current line
nircmd.exe sendkeypress ctrl+shift+t
nircmd.exe clipboard writefile data.txt
nircmd.exe wait 15

echo Line name: >> log.txt
nircmd.exe clipboard addfile log.txt


:: Checks if song is found
set /a found=0
findstr /m "%songName%" data.txt
if %errorlevel%==0 goto Continue

echo %songName% wasn't found >> log.txt
echo %songName% >> notFound.txt
echo Song not found, adding to list...
goto Skip

:Continue
echo Error Level: %errorlevel% >> log.txt
nircmd.exe wait 15
if %slowmode% GTR 0  timeout %slowmode% >nul

:: Searches for Play Count
nircmd.exe clipboard set "Play Count"
nircmd.exe sendkeypress ctrl+v
nircmd.exe sendkey enter press
nircmd.exe wait 15

:: Copies current line
nircmd.exe sendkeypress ctrl+shift+t
nircmd.exe clipboard writefile data.txt

echo Play count line: >> log.txt
nircmd.exe clipboard addfile log.txt

timeout 0 /nobreak >nul
if %slowmode% GTR 0  timeout %slowmode% >nul

:: Run int code

set "first=true"
(for /f "eol=p delims=" %%a in (data.txt) do (
  set "line=%%a"
  if defined first (set "line=!line:~15!" & set "first=")
  <nul set /p ".=!line::=!"
))>output.txt

timeout 0 /nobreak >nul
echo Output file generated >> log.txt

    set "build="
    for /f "tokens=3 delims=<>" %%a in (
        'find /i "<integer>" ^< "output.txt"'
    ) do set "build=%%a"
timeout 0 /nobreak >nul

set /a oldPlays=0
set /a oldPlays=%build%
echo oldPlays: %oldPlays% >> log.txt
echo Song found with %oldPlays% plays
nircmd.exe wait 15

if %slowmode% GTR 0  timeout %slowmode% >nul

:: Click on current plays amount
set /a y=%down%+110
nircmd.exe setcursor -400 %y%
nircmd.exe sendmouse left click
nircmd.exe wait 15

set /a currentPlays=0
:: Grabs current play amount
nircmd.exe sendkeypress ctrl+c
nircmd.exe wait 10
nircmd.exe clipboard writefile data.txt
echo Current plays: >> log.txt
nircmd.exe clipboard addfile log.txt
echo Current plays before load: %currentPlays% >> log.txt
timeout 0 /nobreak >nul
set /p currentPlays=<data.txt
echo Current plays after load: %currentPlays% >> log.txt
nircmd.exe wait 50
if %slowmode% GTR 0  timeout %slowmode% >nul

:: Add numbers together

set /a newPlays = %oldPlays%+%currentPlays%
echo Old: %oldPlays% Current: %currentPlays% New: %newPlays% >> log.txt
echo Adding %currentPlays%, new total is %newPlays% plays >> log.txt
nircmd.exe clipboard set "%newPlays%"

:: Inputs new number
nircmd.exe sendkey 0 press
nircmd.exe wait 20
nircmd.exe sendkeypress ctrl+v
nircmd.exe wait 20
nircmd.exe sendkey enter press
nircmd.exe wait 5
echo Entered value >> log.txt
if %slowmode% GTR 0  timeout %slowmode% >nul

:Skip
echo Clicking down >> log.txt
:: Click down button
nircmd.exe setcursor -25 440
nircmd.exe sendmouse left click
nircmd.exe wait 10
if %slowmode% GTR 0  timeout %slowmode% >nul

:: Can't do last 13, on the last 13 start to go down list

set /a count+=1
set /a checkin+=1
set /a nerfSongs=%totalSongs%-13
if %count% GTR %nerfSongs% set /a down=%down%+23
timeout 1
if %checkin% GEQ 5 (
set /a checkin=0
echo Making sure everything is okay...
timeout 3 /nobreak
)
if %count% LSS %totalSongs% goto Loop
echo Script completed
pause
exit

:Trim
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do set songName=%%b
exit /b
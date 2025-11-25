@echo off
rem ------------------------------------------------------------
rem   Bat-файл для снижения input lag и DPC latency
rem   Автор: Nurthagem
rem ------------------------------------------------------------

:: ---------- 1. Проверяем права администратора ----------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ==============================
    echo Требуются права администратора!
    echo Запустите файл как администратор (ПКМ → “Запуск от имени администратора”).
    echo ==============================
    pause
    exit /b 1
)

:: ---------- 2. Отключаем Game Mode ----------
echo.
echo Проверяем и отключаем Game Mode...
powershell -NoProfile -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Value 0"
if %errorlevel% equ 0 (
    echo Game Mode успешно выключен
) else (
    echo Не удалось изменить настройку Game Mode (возможно, отсутствует)
)

:: ---------- 3. Перезапускаем службу WudfRd ----------
echo.
echo Перезапускаем службу Windows Update Driver Framework...
net stop wudfRd >nul 2>&1
if %errorlevel% equ 0 (
    echo Служба остановлена
) else (
    echo Не удалось остановить службу (возможно, уже выключена)
)

net start wudfRd >nul 2>&1
if %errorlevel% equ 0 (
    echo Служба запущена снова
) else (
    echo Ошибка при запуске службы
)

:: ---------- 4. Устанавливаем режим «Высокая производительность» ----------
echo.
echo Устанавливаем схему питания “Высокая производительность”...
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 1 >nul 2>&1
if %errorlevel% equ 0 (
    echo Схема питания успешно обновлена
) else (
    echo Не удалось изменить схему питания
)

:: ---------- 5. Включаем Ultra‑Low Latency в NVIDIA ----------
echo.
echo Проверяем наличие драйверов NVIDIA...
reg query "HKLM\Software\NVIDIA Corporation" >nul 2>&1
if %errorlevel% equ 0 (
    echo Установлены драйверы NVIDIA – включаем Ultra‑Low Latency
    reg add "HKLM\Software\NVIDIA Corporation\Global\NvControlPanel" /v UltraLowLatencyEnabled /t REG_DWORD /d 1 /f >nul 2>&1
    if %errorlevel% equ 0 (
        echo Ultra‑Low Latency включён
    ) else (
        echo Ошибка при установке параметра Ultra‑Low Latency
    )
) else (
    echo Драйверов NVIDIA не обнаружено
)

:: ---------- 6. Включаем Anti‑Lag в AMD ----------
echo.
echo Проверяем наличие драйверов AMD...
reg query "HKCU\Software\AMD" >nul 2>&1
if %errorlevel% equ 0 (
    echo Установлены драйверы AMD – включаем Anti‑Lag
    reg add "HKCU\Software\AMD\Cortex" /v AntiLagMode /t REG_DWORD /d 1 /f >nul 2>&1
    if %errorlevel% equ 0 (
        echo Anti‑Lag включён
    ) else (
        echo Ошибка при установке параметра Anti‑Lag
    )
) else (
    echo Драйверов AMD не обнаружено
)

:: ---------- 7. Финальный вывод ----------
echo.
echo ==============================
echo Настройки завершены!
echo Перезагрузите компьютер, чтобы изменения вступили в силу.
echo ==============================
pause
exit /b 0
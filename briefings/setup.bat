@echo off
:: 부산 심부름꾼 — 첫 설치 스크립트
:: 바탕화면에서 우클릭 → "관리자 권한으로 실행"으로 실행하세요.

echo [1/3] 환경 변수 파일 확인...
set ENV_FILE=C:\opt\briefing\.env

if not exist "%ENV_FILE%" (
    echo.
    echo .env 파일이 없습니다. 지금 생성합니다.
    echo 아래에 토큰 값을 입력하세요.
    echo.
    set /p GITHUB_TOK="GitHub PAT 토큰 입력: "
    set /p TG_BOT="Telegram Bot Token 입력: "
    set /p TG_CHAT="Telegram Chat ID 입력: "

    echo GITHUB_TOKEN=%GITHUB_TOK% > "%ENV_FILE%"
    echo TELEGRAM_BOT_TOKEN=%TG_BOT% >> "%ENV_FILE%"
    echo TELEGRAM_CHAT_ID=%TG_CHAT% >> "%ENV_FILE%"
    echo.
    echo .env 저장 완료: %ENV_FILE%
) else (
    echo .env 이미 존재 — 건너뜀
)

echo.
echo [2/3] Task Scheduler 등록 중...

schtasks /Create /TN "AI_Briefing_Collect" /TR "\"C:\Program Files\Git\bin\bash.exe\" -c \"/c/opt/briefing/Landing-Page/briefings/collect.sh >> /c/opt/briefing/collect.log 2>&1\"" /SC DAILY /ST 07:30 /RL HIGHEST /F

if %errorlevel% equ 0 (
    echo Task Scheduler 등록 성공!
) else (
    echo Task Scheduler 등록 실패. 수동으로 등록이 필요합니다.
)

echo.
echo [3/3] 즉시 테스트 실행 (선택사항)
set /p RUN_NOW="지금 바로 수집 테스트를 실행할까요? (Y/N): "
if /i "%RUN_NOW%"=="Y" (
    echo 실행 중...
    "C:\Program Files\Git\bin\bash.exe" -c "/c/opt/briefing/Landing-Page/briefings/collect.sh"
    echo 테스트 완료. 로그: C:\opt\briefing\collect.log
)

echo.
echo === 설치 완료 ===
echo 매일 07:30에 AI 브리핑이 자동 수집됩니다.
echo 로그: C:\opt\briefing\collect.log
pause

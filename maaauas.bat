@echo off

@REM encoding:GBK

@REM �����������,���޸ı����ʽ
@REM If Chinese characters are garbled, please modify the encoding format

@REM �Զ���������Դ������MAA
@REM Automatically detect resource updates and launch MAA
@REM ʹ��ǰ����ȷ������ȷ������git����
@REM Before using, ensure that the git environment is correctly configured

setlocal

@REM ��ȡ�ű�����Ŀ¼
@REM Get the directory where the script is located
set "script_dir=%~dp0"
echo �ű�����λ��:%script_dir%
echo Script location: %script_dir%

@REM ����ֿ�Ŀ¼
@REM Define the repository directory
set "repo_dir=%script_dir%updateResourceCache"
echo �ű�����λ��:%repo_dir%
echo Repository directory: %repo_dir%

@REM ���ֿ�Ŀ¼�Ƿ����
@REM Check if the repository directory exists
set updateFlag=0
echo %updateFlag%
if not exist "%repo_dir%" (
    echo �ֿ�Ŀ¼�����ڣ���ʼ��¡...
    echo Repository directory does not exist, starting clone...
    git clone https://github.com/MaaAssistantArknights/MaaResource.git "%repo_dir%"
    if errorlevel 1 (
        echo ��¡ʧ�ܣ��˳��ű���
        echo Clone failed, exiting script.
        exit /b 1
    )
    set updateFlag=1
    echo ��¡��ɡ�
    echo Clone completed.
) else (
    echo �ֿ�Ŀ¼�Ѵ��ڣ���ʼ������...
    echo Repository directory exists, starting update check...
    cd /d "%repo_dir%"
    git fetch origin
    if errorlevel 1 (
        echo ������ʧ�ܣ��˳��ű���
        echo Update check failed, exiting script.
        exit /b 1
    )
    git diff --quiet origin/main
    if errorlevel 1 (
        echo �и��£���ʼ��ȡ...
        echo Updates available, starting pull...
        git reset --hard origin/main
        if errorlevel 1 (
            echo ��ȡʧ�ܣ��˳��ű���
            echo Pull failed, exiting script.
            exit /b 1
        )
        set updateFlag=1
        echo ��ȡ��ɡ�
        echo Pull completed.
    ) else (
        echo �޸��¡�
        echo No updates.
    )
)

@REM ���ؽű�����Ŀ¼
@REM Return to the script's directory
cd /d "%script_dir%"

@REM ����Ƿ��и��£������״ο�¡��
@REM Check if there are updates (including the initial clone)
if %updateFlag% == 1 (
    echo �����µ�resourceĿ¼...
    echo Copying new resource directory...
    xcopy "%repo_dir%\resource" "%script_dir%\resource" /E /I /R /Y > nul
    xcopy "%repo_dir%\cache" "%script_dir%\cache" /E /I /R /Y > nul
    echo ������ɡ�
    echo Update completed.
) else (
    echo û�и���
    echo No updates.
)

endlocal

echo ����MAA
echo Launching MAA
start MAA

@REM �ӳ�������˳�
@REM Delay for 3 seconds before exiting
timeout /t 3 /nobreak >nul
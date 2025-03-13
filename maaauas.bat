@echo off
setlocal

@REM encoding:GBK

@REM �����������,���޸ı����ʽ
@REM If Chinese characters are garbled, please modify the encoding format

@REM ���ű�������MAA��Ŀ¼���������Զ���������Դ������MAA
@REM Place the script in the MAA root directory to automatically detect resource updates and start MAA
@REM ʹ��ǰ����ȷ������ȷ������git����
@REM Before using, ensure that the git environment is correctly configured

@REM ������Դ����git�ֿ��ַ
@REM Set the resource update git repository address
set "git_repo=https://github.com/MaaAssistantArknights/MaaResource.git"

:start_main

echo git�ֿ��ַ:%git_repo%
echo Git repository address: %git_repo%

set updateFlag=0
set errMsg_CN=.
set errMsg_EN=.

@REM ��ȡ�ű�����Ŀ¼
@REM Get the directory where the script is located
set "script_dir=%~dp0"
echo �ű�����λ��:%script_dir%
echo Script location: %script_dir%

@REM ����ֿ�Ŀ¼
@REM Define the repository directory
set "repo_dir=%script_dir%updateResourceCache"
echo ���زֿ�Ŀ¼:%repo_dir%
echo Local repository directory: %repo_dir%

@REM ����Ƿ����git����
@REM Check if there is a git environment
git --version
if %errorlevel% neq 0 (
    cls
    echo.
    echo === ϲ�� ===
    echo.
    echo �޷�ʹ��git����
    echo ����git�Ƿ��Ѱ�װ����ӵ�����������
    echo Cannot use git command
    echo Please check if git is installed and git is added to the environment variables.
    set "errMsg_CN=�޷�ʹ��git����"
    set "errMsg_EN=Cannot use git command"
    goto end_error
)

@REM ����Ƿ����./MAA
@REM Check if there is ./MAA
if not exist "%script_dir%\MAA.exe" (
    cls
    echo.
    echo === ϲ�� ===
    echo.
    echo �޷��ҵ�MAA.exe
    echo �뽫�ű�������MAA��Ŀ¼��
    echo Cannot find MAA.exe
    echo Please place the script in the MAA root directory.
    set "errMsg_CN=�޷��ҵ�MAA.exe"
    set "errMsg_EN=Cannot find MAA.exe"
    goto end_error
)


@REM ���ֿ�Ŀ¼�Ƿ����
@REM Check if the repository directory exists
if not exist "%repo_dir%" (
    echo �ֿ�Ŀ¼�����ڣ���ʼ��¡...
    echo Repository directory does not exist, starting clone...
    git clone "%git_repo%" "%repo_dir%"
    if errorlevel 1 (
        set "errMsg_CN=��¡ʧ�ܣ��˳��ű���"
        set "errMsg_EN=Clone failed, exiting script."
        goto end_error
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
        set "errMsg_CN=������ʧ�ܣ��˳��ű���"
        set "errMsg_EN=Update check failed, exiting script."
        goto end_error
    )
    git diff --quiet origin/main
    if errorlevel 1 (
        echo �и��£���ʼ��ȡ...
        echo Updates available, starting pull...
        git reset --hard origin/main
        if errorlevel 1 (
            set "errMsg_CN=��ȡʧ�ܣ��˳��ű���"
            set "errMsg_EN=Pull failed, exiting script."
            goto end_error
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
start ./MAA
goto end

:end
@REM �ӳ�������˳�
@REM Delay for 3 seconds before exiting
timeout /t 3 /nobreak >nul
exit

:end_error
@REM ���ִ���,��������˳�
color 0C
echo.
echo === ����k��! ===
echo.
@REM ���errMsgΪ.,���
if "%errMsg_CN%"=="." (
    echo.
) else (
    echo %errMsg_CN%
)
@REM If errMsg is ., output
if "%errMsg_EN%"=="." (
    echo.
) else (
    echo %errMsg_EN%
)
echo.
echo ���ִ���,��������˳�
echo An error occurred, press any key to exit
pause >nul
exit

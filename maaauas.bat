@echo off
setlocal
chcp 65001 >nul
@echo off

@REM 将脚本放置在MAA根目录下启动会自动检测更新资源并启动MAA
@REM Place the script in the MAA root directory to automatically detect resource updates and start MAA
@REM 使用前请先确保你正确配置了git环境
@REM Before using, ensure that the git environment is correctly configured

@REM 设置资源更新git仓库地址
@REM Set the resource update git repository address
set "git_repo=https://github.com/MaaAssistantArknights/MaaResource.git"

:start_main

echo git仓库地址:%git_repo%
echo Git repository address: %git_repo%

set updateFlag=0
set errMsg_CN=.
set errMsg_EN=.

@REM 获取脚本所在目录
@REM Get the directory where the script is located
set "script_dir=%~dp0"
echo 脚本所在位置:%script_dir%
echo Script location: %script_dir%

@REM 定义仓库目录
@REM Define the repository directory
set "repo_dir=%script_dir%updateResourceCache"
echo 本地仓库目录:%repo_dir%
echo Local repository directory: %repo_dir%

@REM 检查是否存在git环境
@REM Check if there is a git environment
git --version
if %errorlevel% neq 0 (
    cls
    echo.
    echo === 喜报 ===
    echo.
    echo 无法使用git命令
    echo 请检查git是否已安装且添加到环境变量中
    echo Cannot use git command
    echo Please check if git is installed and git is added to the environment variables.
    set "errMsg_CN=无法使用git命令"
    set "errMsg_EN=Cannot use git command"
    goto end_error
)

@REM 检查是否存在./MAA
@REM Check if there is ./MAA
if not exist "%script_dir%\MAA.exe" (
    cls
    echo.
    echo === 喜报 ===
    echo.
    echo 无法找到MAA.exe
    echo 请将脚本放置在MAA根目录下
    echo Cannot find MAA.exe
    echo Please place the script in the MAA root directory.
    set "errMsg_CN=无法找到MAA.exe"
    set "errMsg_EN=Cannot find MAA.exe"
    goto end_error
)


@REM 检查仓库目录是否存在
@REM Check if the repository directory exists
if not exist "%repo_dir%" (
    echo 仓库目录不存在，开始克隆...
    echo Repository directory does not exist, starting clone...
    git clone "%git_repo%" "%repo_dir%"
    if errorlevel 1 (
        set "errMsg_CN=克隆失败，退出脚本。"
        set "errMsg_EN=Clone failed, exiting script."
        goto end_error
    )
    set updateFlag=1
    echo 克隆完成。
    echo Clone completed.
) else (
    echo 仓库目录已存在，开始检查更新...
    echo Repository directory exists, starting update check...
    cd /d "%repo_dir%"
    git fetch origin
    if errorlevel 1 (
        set "errMsg_CN=检查更新失败，退出脚本。"
        set "errMsg_EN=Update check failed, exiting script."
        goto end_error
    )
    git diff --quiet origin/main
    if errorlevel 1 (
        echo 有更新，开始拉取...
        echo Updates available, starting pull...
        git reset --hard origin/main
        if errorlevel 1 (
            set "errMsg_CN=拉取失败，退出脚本。"
            set "errMsg_EN=Pull failed, exiting script."
            goto end_error
        )
        set updateFlag=1
        echo 拉取完成。
        echo Pull completed.
    ) else (
        echo 无更新。
        echo No updates.
    )
)

@REM 返回脚本所在目录
@REM Return to the script's directory
cd /d "%script_dir%"

@REM 检查是否有更新（包括首次克隆）
@REM Check if there are updates (including the initial clone)
if %updateFlag% == 1 (
    echo 复制新的resource目录...
    echo Copying new resource directory...
    xcopy "%repo_dir%\resource" "%script_dir%\resource" /E /I /R /Y > nul
    xcopy "%repo_dir%\cache" "%script_dir%\cache" /E /I /R /Y > nul
    echo 更新完成。
    echo Update completed.
) else (
    echo 没有更新
    echo No updates.
)

endlocal

echo 启动MAA
echo Launching MAA
start ./MAA
goto end

:end
@REM 延迟三秒后退出
@REM Delay for 3 seconds before exiting
timeout /t 3 /nobreak >nul
exit

:end_error
@REM 出现错误,按任意键退出
color 0C
echo.
echo === エロ発生! ===
echo.
@REM 如果errMsg为.,输出
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
echo 出现错误,按任意键退出
echo An error occurred, press any key to exit
pause >nul
exit

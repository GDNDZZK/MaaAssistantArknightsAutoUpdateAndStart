@echo off

@REM encoding:GBK

@REM 如果中文乱码,请修改编码格式
@REM If Chinese characters are garbled, please modify the encoding format

@REM 自动检测更新资源并启动MAA
@REM Automatically detect resource updates and launch MAA
@REM 使用前请先确保你正确配置了git环境
@REM Before using, ensure that the git environment is correctly configured

setlocal

@REM 获取脚本所在目录
@REM Get the directory where the script is located
set "script_dir=%~dp0"
echo 脚本所在位置:%script_dir%
echo Script location: %script_dir%

@REM 定义仓库目录
@REM Define the repository directory
set "repo_dir=%script_dir%updateResourceCache"
echo 脚本所在位置:%repo_dir%
echo Repository directory: %repo_dir%

@REM 检查仓库目录是否存在
@REM Check if the repository directory exists
set updateFlag=0
echo %updateFlag%
if not exist "%repo_dir%" (
    echo 仓库目录不存在，开始克隆...
    echo Repository directory does not exist, starting clone...
    git clone https://github.com/MaaAssistantArknights/MaaResource.git "%repo_dir%"
    if errorlevel 1 (
        echo 克隆失败，退出脚本。
        echo Clone failed, exiting script.
        exit /b 1
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
        echo 检查更新失败，退出脚本。
        echo Update check failed, exiting script.
        exit /b 1
    )
    git diff --quiet origin/main
    if errorlevel 1 (
        echo 有更新，开始拉取...
        echo Updates available, starting pull...
        git reset --hard origin/main
        if errorlevel 1 (
            echo 拉取失败，退出脚本。
            echo Pull failed, exiting script.
            exit /b 1
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
start MAA

@REM 延迟三秒后退出
@REM Delay for 3 seconds before exiting
timeout /t 3 /nobreak >nul
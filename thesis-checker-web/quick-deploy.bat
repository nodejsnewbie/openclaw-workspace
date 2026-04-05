@echo off
chcp 65001 > nul
cls
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║     毕业论文检查系统 - 云服务器快速部署工具            ║
echo ║     服务器：***.***.***.***                               ║
echo ╚════════════════════════════════════════════════════════╝
echo.

set PROJECT_DIR=e:\repo\openclaw-workspace\thesis-checker-web
set SERVER_IP=***.***.***.***
set SERVER_USER=root
set REMOTE_DIR=/root/projects/thesis-checker-web

echo [检查 1/4] 验证本地项目...
if not exist "%PROJECT_DIR%\docker-compose.yml" (
    echo ❌ 错误：找不到 docker-compose.yml
    pause
    exit /b 1
)
echo ✅ docker-compose.yml 存在

if not exist "%PROJECT_DIR%\frontend\dist\index.html" (
    echo ❌ 错误：前端未构建
    echo 请先执行：cd frontend ^&^& npm run build
    pause
    exit /b 1
)
echo ✅ 前端已构建

if not exist "%PROJECT_DIR%\backend\Dockerfile" (
    echo ❌ 错误：找不到 backend/Dockerfile
    pause
    exit /b 1
)
echo ✅ backend/Dockerfile 存在

echo.
echo [检查 2/4] 验证文件完整性...
if exist "%PROJECT_DIR%\backend\requirements.txt" (
    echo ✅ requirements.txt 存在
) else (
    echo ❌ 缺少 requirements.txt
    pause
    exit /b 1
)

echo.
echo ===========================================================
echo         方式 1：使用 SCP 上传（推荐）
echo ===========================================================
echo.
echo 请打开 Git Bash，执行以下命令：
echo.
echo   scp -r /e/repo/openclaw-workspace/thesis-checker-web root@%SERVER_IP%:%REMOTE_DIR%
echo.
echo ===========================================================
echo.

set /p upload="是否已上传项目文件？(y/n): "
if /i not "%upload%"=="y" (
    cls
    echo.
    echo ===========================================================
    echo         方式 2：使用 FTP 工具上传
    echo ===========================================================
    echo.
    echo 使用 WinSCP 或 FileZilla 连接到服务器：
    echo.
    echo   主机：%SERVER_IP%
    echo   端口：22
    echo   用户：%SERVER_USER%
    echo   密码：[您的服务器密码]
    echo.
    echo 上传目录：%PROJECT_DIR%
    echo 目标路径：%REMOTE_DIR%
    echo.
    echo ===========================================================
    echo.
    set /p ftp="是否已使用 FTP 上传？(y/n): "
    if /i not "%ftp%"=="y" (
        echo.
        echo 请先上传项目文件，然后重新运行此脚本
        pause
        exit /b 0
    )
)

echo.
echo [检查 3/4] 创建服务器部署脚本...

rem 创建服务器端部署脚本
(
echo #!/bin/bash
echo set -e
echo PROJECT_DIR="%REMOTE_DIR%"
echo LOG_FILE="/var/log/thesis-checker-deploy.log"
echo.
echo echo "========================================" ^|^| tee -a "$LOG_FILE"
echo echo "  毕业论文检查系统 - 部署脚本" ^|^| tee -a "$LOG_FILE"
echo echo "========================================" ^|^| tee -a "$LOG_FILE"
echo echo "开始时间: $(date)" ^|^| tee -a "$LOG_FILE"
echo echo "" ^|^| tee -a "$LOG_FILE"
echo.
echo # 创建项目目录
echo mkdir -p "$PROJECT_DIR"
echo cd "$PROJECT_DIR"
echo.
echo echo "[1/5] 停止旧容器..." ^|^| tee -a "$LOG_FILE"
echo docker-compose down 2^>^&1 ^|^| tee -a "$LOG_FILE" ^|^| true
echo.
echo echo "[2/5] 检查必要文件..." ^|^| tee -a "$LOG_FILE"
echo if [ ! -f "docker-compose.yml" ]; then
echo     echo "❌ 错误：找不到 docker-compose.yml" ^|^| tee -a "$LOG_FILE"
echo     exit 1
echo fi
echo if [ ! -f "backend/Dockerfile" ]; then
echo     echo "❌ 错误：找不到 backend/Dockerfile" ^|^| tee -a "$LOG_FILE"
echo     exit 1
echo fi
echo echo "✅ 必要文件检查通过" ^|^| tee -a "$LOG_FILE"
echo.
echo echo "[3/5] 清理旧镜像..." ^|^| tee -a "$LOG_FILE"
echo docker system prune -f 2^>^&1 ^|^| tee -a "$LOG_FILE" ^|^| true
echo.
echo echo "[4/5] 构建并启动服务..." ^|^| tee -a "$LOG_FILE"
echo docker-compose up -d --build 2^>^&1 ^|^| tee -a "$LOG_FILE"
echo.
echo echo "[5/5] 等待服务启动..." ^|^| tee -a "$LOG_FILE"
echo sleep 20
echo.
echo echo "" ^|^| tee -a "$LOG_FILE"
echo echo "容器状态：" ^|^| tee -a "$LOG_FILE"
echo docker-compose ps 2^>^&1 ^|^| tee -a "$LOG_FILE"
echo.
echo echo "最新日志：" ^|^| tee -a "$LOG_FILE"
echo docker-compose logs --tail=50 2^>^&1 ^|^| tee -a "$LOG_FILE"
echo.
echo echo "" ^|^| tee -a "$LOG_FILE"
echo echo "========================================" ^|^| tee -a "$LOG_FILE"
echo echo "  ✅ 部署完成！" ^|^| tee -a "$LOG_FILE"
echo echo "========================================" ^|^| tee -a "$LOG_FILE"
echo echo "完成时间: $(date)" ^|^| tee -a "$LOG_FILE"
echo echo "" ^|^| tee -a "$LOG_FILE"
echo echo "🌐 访问地址：" ^|^| tee -a "$LOG_FILE"
echo echo "  - 前端：http://%SERVER_IP%:8000" ^|^| tee -a "$LOG_FILE"
echo echo "  - API：http://%SERVER_IP%:8000/api" ^|^| tee -a "$LOG_FILE"
echo echo "  - API文档：http://%SERVER_IP%:8000/docs" ^|^| tee -a "$LOG_FILE"
echo echo "" ^|^| tee -a "$LOG_FILE"
) > "%PROJECT_DIR%\server-setup.sh"

echo ✅ 服务器部署脚本已创建

echo.
echo ===========================================================
echo         现在需要在服务器上执行部署
echo ===========================================================
echo.
echo 请 SSH 连接到服务器并执行以下命令：
echo.
echo   ssh root@%SERVER_IP%
echo.
echo 然后执行：
echo.
echo   cd %REMOTE_DIR%
echo   docker-compose up -d --build
echo.
echo 或者复制上面的 server-setup.sh 到服务器并执行
echo.
echo ===========================================================
echo.

set /p continue="是否已完成部署？(y/n): "
if /i not "%continue%"=="y" (
    echo.
    echo 请先完成服务器部署，然后重新运行此脚本进行验证
    pause
    exit /b 0
)

echo.
echo [检查 4/4] 部署验证...
echo.
echo ===========================================================
echo           部署完成信息
echo ===========================================================
echo.
echo 🌐 访问地址：
echo   - 前端应用：http://%SERVER_IP%:8000
echo   - 后端API：http://%SERVER_IP%:8000/api
echo   - API文档：http://%SERVER_IP%:8000/docs
echo.
echo 🔧 服务器管理命令：
echo.
echo   连接服务器：
echo     ssh root@%SERVER_IP%
echo.
echo   查看服务状态：
echo     cd %REMOTE_DIR% ^&^& docker-compose ps
echo.
echo   查看日志：
echo     cd %REMOTE_DIR% ^&^& docker-compose logs -f
echo.
echo   停止服务：
echo     cd %REMOTE_DIR% ^&^& docker-compose down
echo.
echo   重启服务：
echo     cd %REMOTE_DIR% ^&^& docker-compose restart
echo.
echo   更新服务（修改代码后）：
echo     cd %REMOTE_DIR% ^&^& docker-compose down ^&^& docker-compose up -d --build
echo.
echo ===========================================================
echo.
echo ✅ 部署脚本已准备完成！
echo.
echo 下一步：
echo   1. 上传项目文件到服务器
echo   2. SSH 连接到服务器
echo   3. 执行 docker-compose up -d --build
echo   4. 访问 http://%SERVER_IP%:8000 验证部署
echo.
pause

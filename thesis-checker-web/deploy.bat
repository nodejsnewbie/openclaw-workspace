@echo off
chcp 65001 > nul
echo ========================================
echo   毕业论文检查系统 - 自动部署工具
echo ========================================
echo.

set SERVER_IP=***.***.***.***
set SERVER_USER=root
set LOCAL_PROJECT=e:\repo\openclaw-workspace\thesis-checker-web
set REMOTE_PROJECT=/root/projects/thesis-checker-web

echo [1/6] 检查本地项目...
if not exist "%LOCAL_PROJECT%" (
    echo ❌ 错误：项目目录不存在
    pause
    exit /b 1
)
echo ✅ 项目目录存在

if not exist "%LOCAL_PROJECT%\docker-compose.yml" (
    echo ❌ 错误：找不到 docker-compose.yml
    pause
    exit /b 1
)
echo ✅ docker-compose.yml 存在

if not exist "%LOCAL_PROJECT%\frontend\dist\index.html" (
    echo ❌ 错误：前端未构建，请先执行：cd frontend ^&^& npm run build
    pause
    exit /b 1
)
echo ✅ 前端已构建

if not exist "%LOCAL_PROJECT%\backend\Dockerfile" (
    echo ❌ 错误：找不到 backend/Dockerfile
    pause
    exit /b 1
)
echo ✅ backend/Dockerfile 存在

echo.
echo [2/6] 初始化 Git 仓库...
cd /d "%LOCAL_PROJECT%"
if exist ".git" (
    echo ✅ Git 仓库已存在
) else (
    echo 正在初始化 Git 仓库...
    git init 2>nul || echo "警告：Git 初始化失败，跳过"
    echo ✅ Git 仓库已初始化
)

echo.
echo [3/6] 添加文件到暂存区...
git add . 2>nul || echo "警告：Git add 失败，跳过"

echo.
echo [4/6] 提交代码...
git commit -m "Auto deploy: update project files" 2>nul || echo "警告：Git commit 失败，跳过"

echo.
echo [5/6] 上传项目到服务器...
echo.
echo ===================================================
echo   需要手动上传项目文件到服务器
echo ===================================================
echo.
echo 方式1：使用 SCP 上传（推荐）
echo   在 Git Bash 中执行：
echo   scp -r /e/repo/openclaw-workspace/thesis-checker-web root@%SERVER_IP%:%REMOTE_PROJECT%
echo.
echo 方式2：使用 FTP 工具上传
echo   使用 WinSCP、FileZilla 等工具连接到 %SERVER_IP%
echo   上传目录：%LOCAL_PROJECT%
echo   目标路径：%REMOTE_PROJECT%
echo.
echo 方式3：先推送到 Git 仓库，然后在服务器克隆
echo   1. 将代码推送到 Git 仓库（Gitee、GitHub 等）
echo   2. SSH 连接到服务器：ssh root@%SERVER_IP%
echo   3. 克隆项目：git clone ^<仓库地址^> %REMOTE_PROJECT%
echo.
echo ===================================================
echo.
set /p choice="是否已手动上传项目？(y/n): "
if /i not "%choice%"=="y" (
    echo.
    echo 请先上传项目文件，然后重新运行此脚本
    pause
    exit /b 0
)

echo.
echo [6/6] 在服务器上部署项目...
echo.
echo 正在连接服务器执行部署...
echo.

rem 创建远程部署脚本内容
set DEPLOY_SCRIPT=# 创建部署目录^
mkdir -p %REMOTE_PROJECT% ^&^& ^

# 创建服务更新脚本
cat > /root/update-thesis-checker.sh << 'EOFSCRIPT'
#!/bin/bash
set -e
cd %REMOTE_PROJECT%
echo "停止旧容器..."
docker-compose down
echo "构建并启动服务..."
docker-compose up -d --build
echo "等待服务启动..."
sleep 15
echo "服务状态："
docker-compose ps
echo "最新日志："
docker-compose logs --tail=30
echo "部署完成！"
echo "访问地址：http://%SERVER_IP%:8000"
EOFSCRIPT

chmod +x /root/update-thesis-checker.sh

# 执行部署
/root/update-thesis-checker.sh

echo.
echo ===================================================
echo   ✅ 部署完成！
echo ===================================================
echo.
echo 🌐 访问地址：
echo   - 前端应用：http://%SERVER_IP%:8000
echo   - 后端API：http://%SERVER_IP%:8000/api
echo   - API文档：http://%SERVER_IP%:8000/docs
echo.
echo 🔧 服务器管理命令：
echo   - 查看日志：ssh root@%SERVER_IP% "cd %REMOTE_PROJECT% ^&^& docker-compose logs -f"
echo   - 停止服务：ssh root@%SERVER_IP% "cd %REMOTE_PROJECT% ^&^& docker-compose down"
echo   - 重启服务：ssh root@%SERVER_IP% "cd %REMOTE_PROJECT% ^&^& docker-compose restart"
echo   - 更新服务：ssh root@%SERVER_IP% "/root/update-thesis-checker.sh"
echo.

pause

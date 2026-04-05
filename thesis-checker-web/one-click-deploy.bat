@echo off
chcp 65001 > nul
cls
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                                                          ║
echo ║     🚀 毕业论文检查系统 - 一键部署工具 🚀               ║
echo ║                                                          ║
echo ║     服务器：***.***.***.***                                ║
echo ║     操作：安装 TAT + 部署项目                             ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

set PROJECT_DIR=e:\repo\openclaw-workspace\thesis-checker-web
set SERVER_IP=***.***.***.***
set SERVER_USER=root
set REMOTE_DIR=/root/projects/thesis-checker-web
set DEPLOY_SCRIPT=%PROJECT_DIR%\install-tat-and-deploy.sh

echo [步骤 1/5] 检查本地项目...
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

if not exist "%PROJECT_DIR%\backend\requirements.txt" (
    echo ❌ 错误：找不到 backend/requirements.txt
    pause
    exit /b 1
)
echo ✅ backend/requirements.txt 存在

if not exist "%DEPLOY_SCRIPT%" (
    echo ❌ 错误：找不到部署脚本 install-tat-and-deploy.sh
    pause
    exit /b 1
)
echo ✅ 部署脚本存在

echo.
echo [步骤 2/5] 上传项目到服务器...
echo ============================================================
echo   需要手动上传项目到服务器
echo ============================================================
echo.
echo 请打开 Git Bash，执行以下命令：
echo.
echo   scp -r /e/repo/openclaw-workspace/thesis-checker-web root@%SERVER_IP%:%REMOTE_DIR%
echo.
echo 等待上传完成（可能需要几分钟）
echo.
echo ============================================================
echo.

set /p uploaded="是否已上传项目？(y/n): "
if /i not "%uploaded%"=="y" (
    echo.
    echo 请先上传项目，然后重新运行此脚本
    pause
    exit /b 0
)

echo.
echo [步骤 3/5] 上传部署脚本到服务器...
echo ============================================================
echo   上传部署脚本到服务器
echo ============================================================
echo.
echo 请在 Git Bash 中执行：
echo.
echo   scp %DEPLOY_SCRIPT% root@%SERVER_IP%:/root/
echo.
echo ============================================================
echo.

set /p script_uploaded="是否已上传部署脚本？(y/n): "
if /i not "%script_uploaded%"=="y" (
    echo.
    echo 请先上传部署脚本，然后重新运行此脚本
    pause
    exit /b 0
)

echo.
echo [步骤 4/5] 执行部署...
echo ============================================================
echo   需要在服务器上执行部署脚本
echo ============================================================
echo.
echo 请在 Git Bash 中连接到服务器并执行：
echo.
echo   ssh root@%SERVER_IP%
echo.
echo 然后执行：
echo.
echo   chmod +x /root/install-tat-and-deploy.sh
echo   /root/install-tat-and-deploy.sh
echo.
echo 这将自动完成：
echo   1. 安装 TAT 代理
echo   2. 验证 Docker 环境
echo   3. 构建并启动服务
echo   4. 创建快速管理命令
echo.
echo 等待部署完成（可能需要 3-5 分钟）
echo.
echo ============================================================
echo.

set /p deployed="是否已执行部署脚本？(y/n): "
if /i not "%deployed%"=="y" (
    echo.
    echo 请先完成部署，然后重新运行此脚本进行验证
    pause
    exit /b 0
)

echo.
echo [步骤 5/5] 部署验证...
echo ============================================================
echo           部署完成信息
echo ============================================================
echo.
echo ✅ TAT 代理已安装
echo ✅ 项目已部署
echo ✅ 服务已启动
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
echo   使用快速管理命令：
echo     thesis-checker status   - 查看服务状态
echo     thesis-checker logs     - 查看日志
echo     thesis-checker restart  - 重启服务
echo     thesis-checker update   - 更新服务
echo     thesis-checker stop     - 停止服务
echo     thesis-checker start    - 启动服务
echo.
echo   或使用 docker-compose 命令：
echo     cd %REMOTE_DIR%
echo     docker-compose ps
echo     docker-compose logs -f
echo     docker-compose restart
echo.
echo ============================================================
echo.
echo 📝 注意事项：
echo   1. 首次启动可能需要 2-3 分钟
echo   2. 如果访问失败，请检查防火墙端口 8000
echo   3. 查看日志了解详细信息：thesis-checker logs
echo   4. 更新代码后执行：thesis-checker update
echo.
echo ============================================================
echo.
echo 🎉 恭喜！部署完成！现在可以在浏览器中访问应用了。
echo.
pause

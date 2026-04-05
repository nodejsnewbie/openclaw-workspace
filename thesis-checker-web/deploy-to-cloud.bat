@echo off
chcp 65001 > nul
echo ========================================
echo   毕业论文检查系统 - 云服务器部署工具
echo ========================================
echo.

set SERVER_IP=***.***.***.***
set SERVER_USER=root
set LOCAL_PROJECT=e:\repo\openclaw-workspace\thesis-checker-web
set REMOTE_PROJECT=/root/projects/thesis-checker-web

echo [1/5] 检查本地项目目录...
if not exist "%LOCAL_PROJECT%" (
    echo ❌ 错误：项目目录不存在：%LOCAL_PROJECT%
    pause
    exit /b 1
)
echo ✅ 项目目录存在

echo.
echo [2/5] 检查必要文件...
if not exist "%LOCAL_PROJECT%\docker-compose.yml" (
    echo ❌ 错误：找不到 docker-compose.yml 文件
    pause
    exit /b 1
)
echo ✅ docker-compose.yml 存在

if not exist "%LOCAL_PROJECT%\backend\Dockerfile" (
    echo ❌ 错误：找不到 backend/Dockerfile 文件
    pause
    exit /b 1
)
echo ✅ backend/Dockerfile 存在

if not exist "%LOCAL_PROJECT%\backend\requirements.txt" (
    echo ❌ 错误：找不到 backend/requirements.txt 文件
    pause
    exit /b 1
)
echo ✅ backend/requirements.txt 存在

if not exist "%LOCAL_PROJECT%\frontend\dist\index.html" (
    echo ❌ 错误：找不到前端构建文件（frontend/dist/index.html）
    echo 请先构建前端：cd frontend && npm run build
    pause
    exit /b 1
)
echo ✅ 前端构建文件存在

echo.
echo [3/5] 上传项目文件到服务器...
echo 正在上传文件到 %SERVER_IP%，这可能需要几分钟...

rem 使用 pscp（PuTTY Secure Copy Client）上传文件
rem 如果没有 pscp，请先安装 PuTTY
where pscp >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：找不到 pscp 命令
    echo 请先安装 PuTTY：https://www.putty.org/
    pause
    exit /b 1
)

rem 创建远程目录
pscp -batch -pw "" %LOCAL_PROJECT%\docker-compose.yml %SERVER_USER%@%SERVER_IP%:/tmp/
if %errorlevel% neq 0 (
    echo ⚠️  警告：需要手动输入 SSH 密码
)

rem 上传整个项目（排除 node_modules、.git 等目录）
echo 上传项目文件（排除不必要文件）...
pscp -r -batch -C -p %LOCAL_PROJECT%\* %SERVER_USER%@%SERVER_IP%:%REMOTE_PROJECT%

echo.
echo [4/5] 在服务器上执行部署...
echo 正在连接服务器执行部署脚本...

rem 使用 plink 执行远程命令
where plink >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：找不到 plink 命令
    echo 请先安装 PuTTY：https://www.putty.org/
    pause
    exit /b 1
)

plink -batch %SERVER_USER%@%SERVER_IP% "mkdir -p /root/projects && cd /root/projects && if [ -d 'thesis-checker-web' ]; then cd thesis-checker-web && docker-compose down; else echo '首次部署'; fi"

rem 执行部署脚本
plink -batch %SERVER_USER%@%SERVER_IP% "cd /root/projects/thesis-checker-web && docker-compose up -d"

echo.
echo [5/5] 验证部署状态...
plink -batch %SERVER_USER%@%SERVER_IP% "docker-compose -f /root/projects/thesis-checker-web/docker-compose.yml ps"

echo.
echo ========================================
echo   ✅ 部署完成！
echo ========================================
echo.
echo 🌐 访问地址：
echo   - 前端应用：http://%SERVER_IP%:8000
echo   - 后端API：http://%SERVER_IP%:8000/api
echo   - API文档：http://%SERVER_IP%:8000/docs
echo.
echo 🔧 查看日志：
echo   plink %SERVER_USER%@%SERVER_IP% "cd /root/projects/thesis-checker-web && docker-compose logs -f"
echo.
echo 📝 常用命令：
echo   - 停止服务：plink %SERVER_USER%@%SERVER_IP% "cd /root/projects/thesis-checker-web && docker-compose down"
echo   - 重启服务：plink %SERVER_USER%@%SERVER_IP% "cd /root/projects/thesis-checker-web && docker-compose restart"
echo   - 查看状态：plink %SERVER_USER%@%SERVER_IP% "cd /root/projects/thesis-checker-web && docker-compose ps"
echo.

pause

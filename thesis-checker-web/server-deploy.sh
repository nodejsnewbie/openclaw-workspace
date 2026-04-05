#!/bin/bash

# ========================================
# 毕业论文检查系统 - 服务器端部署脚本
# ========================================

set -e  # 遇到错误立即退出

SERVER_IP="***.***.***.***"
PROJECT_DIR="/root/projects/thesis-checker-web"
LOG_FILE="/var/log/thesis-checker-deploy.log"

echo "========================================" | tee -a "$LOG_FILE"
echo "  毕业论文检查系统 - 自动部署脚本" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "开始时间: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 检查 Docker 是否安装
echo "[1/8] 检查 Docker 环境..." | tee -a "$LOG_FILE"
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker" | tee -a "$LOG_FILE"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose" | tee -a "$LOG_FILE"
    exit 1
fi

echo "✅ Docker 版本: $(docker --version)" | tee -a "$LOG_FILE"
echo "✅ Docker Compose 版本: $(docker-compose --version)" | tee -a "$LOG_FILE"

# 创建项目目录
echo "" | tee -a "$LOG_FILE"
echo "[2/8] 创建项目目录..." | tee -a "$LOG_FILE"
mkdir -p "$PROJECT_DIR"
echo "✅ 项目目录: $PROJECT_DIR" | tee -a "$LOG_FILE"

# 停止旧容器
echo "" | tee -a "$LOG_FILE"
echo "[3/8] 停止旧容器..." | tee -a "$LOG_FILE"
cd "$PROJECT_DIR" 2>/dev/null || true
if [ -f "docker-compose.yml" ]; then
    echo "停止并删除旧容器..." | tee -a "$LOG_FILE"
    docker-compose down 2>&1 | tee -a "$LOG_FILE" || true
else
    echo "首次部署，无需停止旧容器" | tee -a "$LOG_FILE"
fi

# 检查必要文件
echo "" | tee -a "$LOG_FILE"
echo "[4/8] 检查项目文件..." | tee -a "$LOG_FILE"
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ 错误：找不到 docker-compose.yml 文件" | tee -a "$LOG_FILE"
    exit 1
fi
echo "✅ docker-compose.yml 存在" | tee -a "$LOG_FILE"

if [ ! -f "backend/Dockerfile" ]; then
    echo "❌ 错误：找不到 backend/Dockerfile 文件" | tee -a "$LOG_FILE"
    exit 1
fi
echo "✅ backend/Dockerfile 存在" | tee -a "$LOG_FILE"

if [ ! -f "backend/requirements.txt" ]; then
    echo "❌ 错误：找不到 backend/requirements.txt 文件" | tee -a "$LOG_FILE"
    exit 1
fi
echo "✅ backend/requirements.txt 存在" | tee -a "$LOG_FILE"

if [ ! -f "frontend/dist/index.html" ]; then
    echo "❌ 错误：找不到前端构建文件（frontend/dist/index.html）" | tee -a "$LOG_FILE"
    echo "请先构建前端：cd frontend && npm run build" | tee -a "$LOG_FILE"
    exit 1
fi
echo "✅ 前端构建文件存在" | tee -a "$LOG_FILE"

# 清理旧镜像（可选）
echo "" | tee -a "$LOG_FILE"
echo "[5/8] 清理旧镜像..." | tee -a "$LOG_FILE"
docker system prune -f 2>&1 | tee -a "$LOG_FILE" || true

# 构建并启动服务
echo "" | tee -a "$LOG_FILE"
echo "[6/8] 构建并启动服务..." | tee -a "$LOG_FILE"
docker-compose up -d --build 2>&1 | tee -a "$LOG_FILE"

# 等待服务启动
echo "" | tee -a "$LOG_FILE"
echo "[7/8] 等待服务启动..." | tee -a "$LOG_FILE"
sleep 15

# 检查服务状态
echo "" | tee -a "$LOG_FILE"
echo "[8/8] 检查服务状态..." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "容器状态：" | tee -a "$LOG_FILE"
docker-compose ps 2>&1 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "最近日志：" | tee -a "$LOG_FILE"
docker-compose logs --tail=20 2>&1 | tee -a "$LOG_FILE"

# 检查端口监听
echo "" | tee -a "$LOG_FILE"
echo "端口监听状态：" | tee -a "$LOG_FILE"
netstat -tlnp | grep -E ':(8000|27017)' 2>&1 | tee -a "$LOG_FILE" || ss -tlnp | grep -E ':(8000|27017)' 2>&1 | tee -a "$LOG_FILE" || echo "无法获取端口信息" | tee -a "$LOG_FILE"

# 部署完成
echo "" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "  ✅ 部署完成！" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "完成时间: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "🌐 访问地址：" | tee -a "$LOG_FILE"
echo "  - 前端应用：http://$SERVER_IP:8000" | tee -a "$LOG_FILE"
echo "  - 后端API：http://$SERVER_IP:8000/api" | tee -a "$LOG_FILE"
echo "  - API文档：http://$SERVER_IP:8000/docs" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "🔧 常用命令：" | tee -a "$LOG_FILE"
echo "  - 查看日志：cd $PROJECT_DIR && docker-compose logs -f" | tee -a "$LOG_FILE"
echo "  - 停止服务：cd $PROJECT_DIR && docker-compose down" | tee -a "$LOG_FILE"
echo "  - 重启服务：cd $PROJECT_DIR && docker-compose restart" | tee -a "$LOG_FILE"
echo "  - 查看状态：cd $PROJECT_DIR && docker-compose ps" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 创建快速启动脚本
cat > /usr/local/bin/thesis-checker << 'EOF'
#!/bin/bash
cd /root/projects/thesis-checker-web
case "$1" in
    start)
        docker-compose up -d
        ;;
    stop)
        docker-compose down
        ;;
    restart)
        docker-compose restart
        ;;
    logs)
        docker-compose logs -f
        ;;
    status)
        docker-compose ps
        ;;
    *)
        echo "用法: thesis-checker {start|stop|restart|logs|status}"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/thesis-checker

echo "✅ 快速启动命令已创建：thesis-checker {start|stop|restart|logs|status}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

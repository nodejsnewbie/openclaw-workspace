#!/bin/bash

# ========================================
# 安装 TAT 并部署毕业论文检查系统
# ========================================

set -e

SERVER_IP="***.***.***.***"
PROJECT_DIR="/root/projects/thesis-checker-web"
LOG_FILE="/var/log/tat-install-deploy.log"

echo "========================================" | tee -a "$LOG_FILE"
echo "  TAT 安装和项目部署脚本" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "开始时间: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 1: 安装 TAT 代理
echo "[1/7] 安装 TAT 代理..." | tee -a "$LOG_FILE"
echo "下载 TAT 代理安装脚本..."

# 下载 TAT 代理安装脚本
curl -sSL 'http://tat-agent-1258344699.cos.ap-guangzhou.myqcloud.com/tat_agent_linux_amd64/tat_agent_install.sh' -o /tmp/tat_agent_install.sh

if [ ! -f /tmp/tat_agent_install.sh ]; then
    echo "❌ TAT 代理安装脚本下载失败" | tee -a "$LOG_FILE"
    exit 1
fi

echo "执行 TAT 代理安装..."
chmod +x /tmp/tat_agent_install.sh
/tmp/tat_agent_install.sh

# 检查 TAT 服务状态
echo "检查 TAT 服务状态..."
systemctl status tat_agent || true

echo "✅ TAT 代理安装完成" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 2: 验证 Docker
echo "[2/7] 验证 Docker 环境..." | tee -a "$LOG_FILE"
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装" | tee -a "$LOG_FILE"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装" | tee -a "$LOG_FILE"
    exit 1
fi

echo "✅ Docker 版本: $(docker --version)" | tee -a "$LOG_FILE"
echo "✅ Docker Compose 版本: $(docker-compose --version)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 3: 创建项目目录
echo "[3/7] 创建项目目录..." | tee -a "$LOG_FILE"
mkdir -p "$PROJECT_DIR"
echo "✅ 项目目录: $PROJECT_DIR" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 4: 检查项目文件
echo "[4/7] 检查项目文件..." | tee -a "$LOG_FILE"
cd "$PROJECT_DIR"

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ 错误：找不到 docker-compose.yml" | tee -a "$LOG_FILE"
    echo "请先上传项目文件到 $PROJECT_DIR" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -f "backend/Dockerfile" ]; then
    echo "❌ 错误：找不到 backend/Dockerfile" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -f "backend/requirements.txt" ]; then
    echo "❌ 错误：找不到 backend/requirements.txt" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -f "frontend/dist/index.html" ]; then
    echo "❌ 错误：找不到前端构建文件" | tee -a "$LOG_FILE"
    exit 1
fi

echo "✅ 所有必要文件检查通过" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 5: 停止旧容器
echo "[5/7] 停止旧容器..." | tee -a "$LOG_FILE"
docker-compose down 2>&1 | tee -a "$LOG_FILE" || true
echo "✅ 旧容器已停止" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 6: 构建并启动服务
echo "[6/7] 构建并启动服务..." | tee -a "$LOG_FILE"
docker-compose up -d --build 2>&1 | tee -a "$LOG_FILE"

# 等待服务启动
echo "等待服务启动..."
sleep 25

echo "✅ 服务已启动" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 步骤 7: 检查服务状态
echo "[7/7] 检查服务状态..." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "容器状态：" | tee -a "$LOG_FILE"
docker-compose ps 2>&1 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "最新日志：" | tee -a "$LOG_FILE"
docker-compose logs --tail=50 2>&1 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "端口监听状态：" | tee -a "$LOG_FILE"
netstat -tlnp | grep -E ':(8000|27017)' 2>&1 | tee -a "$LOG_FILE" || ss -tlnp | grep -E ':(8000|27017)' 2>&1 | tee -a "$LOG_FILE"

# 创建快速管理脚本
echo "" | tee -a "$LOG_FILE"
echo "创建快速管理脚本..." | tee -a "$LOG_FILE"

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
    update)
        docker-compose down
        docker-compose up -d --build
        ;;
    *)
        echo "用法: thesis-checker {start|stop|restart|logs|status|update}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/thesis-checker

echo "✅ 快速管理命令已创建" | tee -a "$LOG_FILE"
echo "  使用方法: thesis-checker {start|stop|restart|logs|status|update}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 部署完成
echo "========================================" | tee -a "$LOG_FILE"
echo "  ✅ 安装和部署完成！" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "完成时间: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "🌐 访问地址：" | tee -a "$LOG_FILE"
echo "  - 前端应用：http://$SERVER_IP:8000" | tee -a "$LOG_FILE"
echo "  - 后端API：http://$SERVER_IP:8000/api" | tee -a "$LOG_FILE"
echo "  - API文档：http://$SERVER_IP:8000/docs" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "🔧 管理命令：" | tee -a "$LOG_FILE"
echo "  - 查看状态：thesis-checker status" | tee -a "$LOG_FILE"
echo "  - 查看日志：thesis-checker logs" | tee -a "$LOG_FILE"
echo "  - 重启服务：thesis-checker restart" | tee -a "$LOG_FILE"
echo "  - 更新服务：thesis-checker update" | tee -a "$LOG_FILE"
echo "  - 停止服务：thesis-checker stop" | tee -a "$LOG_FILE"
echo "  - 启动服务：thesis-checker start" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "========================================" | tee -a "$LOG_FILE"
echo "  🎉 恭喜！部署成功！" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

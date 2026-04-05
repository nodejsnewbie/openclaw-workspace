#!/bin/bash

# 毕业论文检查系统 - 服务器启动脚本

set -e

echo "========================================"
echo "  毕业论文检查系统 - 启动服务"
echo "========================================"
echo ""

# 进入后端目录
cd /root/projects/thesis-checker-web/backend

# 检查 Python 环境
echo "[1/4] 检查 Python 环境..."
python3 --version
echo ""

# 安装依赖
echo "[2/4] 安装 Python 依赖..."
pip3 install -r requirements.txt --quiet
echo "✅ 依赖安装完成"
echo ""

# 创建必要目录
echo "[3/4] 创建必要目录..."
mkdir -p uploads reports requirements templates
echo "✅ 目录创建完成"
echo ""

# 启动服务
echo "[4/4] 启动后端服务..."
echo "服务将在后台运行..."
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > /tmp/thesis-backend.log 2>&1 &

# 获取进程 ID
PID=$!
echo "进程 ID: $PID"

# 等待服务启动
echo "等待服务启动..."
sleep 15

# 检查服务状态
echo ""
echo "检查服务状态..."
if ps -p $PID > /dev/null; then
    echo "✅ 服务启动成功！"
    echo ""
    echo "测试访问..."
    curl -s http://localhost:8000 | head -10 || echo "访问测试失败，请检查日志"

    echo ""
    echo "========================================"
    echo "  🎉 服务已启动！"
    echo "========================================"
    echo ""
    echo "🌐 访问地址："
    echo "  - 前端应用：http://***.***.***.***:8000"
    echo "  - 后端API：http://***.***.***.***:8000/api"
    echo "  - API文档：http://***.***.***.***:8000/docs"
    echo ""
    echo "📋 管理命令："
    echo "  - 查看日志：tail -f /tmp/thesis-backend.log"
    echo "  - 停止服务：pkill -f uvicorn"
    echo "  - 重启服务：bash /root/start-server.sh"
    echo ""
else
    echo "❌ 服务启动失败"
    echo ""
    echo "查看日志："
    cat /tmp/thesis-backend.log
fi

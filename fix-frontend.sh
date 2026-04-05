#!/bin/bash
# 在服务器上执行此脚本来启动前端服务

echo "正在检查Docker容器..."
docker ps -a | grep thesis

echo ""
echo "启动前端Nginx容器..."
docker stop thesis-frontend 2>/dev/null || true
docker rm thesis-frontend 2>/dev/null || true

docker run -d --name thesis-frontend --restart always \
  -p 80:80 \
  -v /root/frontend:/usr/share/nginx/html:ro \
  nginx:alpine

echo ""
echo "等待容器启动..."
sleep 3

echo ""
echo "检查容器状态..."
docker ps | grep thesis-frontend

echo ""
echo "测试本地访问..."
curl -I http://localhost

echo ""
echo "完成！前端应该可以通过 http://***.***.***.*** 访问了"
